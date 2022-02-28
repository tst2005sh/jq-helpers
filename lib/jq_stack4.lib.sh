
jq_stack4() {
	local self=jq_stack4
	while [ $# -gt 0 ]; do
		case "$1" in
		(:rawdef)	echo >&2 "OBSOLETED; Use $self :function instead of $self :rawdef"; return 1;;
		(:locals)	echo >&2 "OBSOLETED"; return 1;;
#		(:rawdef)	shift; set -- :function "$@";;
#		(:locals)	return 0;;
		esac

		case "$1" in
		(:autoinit)	JQ_STACK4_AUTOINIT=true ;shift;continue;;
		(:noautoinit)	JQ_STACK4_AUTOINIT=false;shift;continue;;
		(:fallback)	JQ_STACK4_FALLBACK=true ;shift;continue;;
		(:nofallback)	JQ_STACK4_FALLBACK=false;shift;continue;;
		(:init)
			JQ_STACK4_TMP="$(mktemp -q /dev/shm/$self.tmp.XXXXXXXX || mktemp /tmp/$self.tmp.XXXXXXXX)" || return 1
			shift;continue
		;;
		(:deinit)
			[ -z "$JQ_STACK4_TMP" ] || [ ! -f "$JQ_STACK4_TMP" ] || rm -f "$JQ_STACK4_TMP" >&2
			shift;continue
		;;
		esac
		if [ -z "$JQ_STACK4_TMP" ] || [ ! -f "$JQ_STACK4_TMP" ]; then
			if [ "${JQ_STACK4_AUTOINIT:-true}" != true ]; then
				echo >&2 "ERROR: ${self}: not initialized (auto init is disabled). Use \"$self :init\" before this action (or enable auto init with \"$self :autoinit\")"
				return 1
			fi
			# nostrict, auto init
			$self :init
		fi
		case "$1" in
		(:call|:option)
			jq -ncM --arg arg1 "${1#:}" --arg arg2 "$2" '{($arg1):$arg2}' >> "$JQ_STACK4_TMP"
			shift
		;;
		(:precall)
			jq -ncM --arg arg2 "$2" '{"call":$arg2,"pre":-1}' >> "$JQ_STACK4_TMP"
			shift
		;;
		(:function)
			local funcdefclean='def funcdefclean:
				if type=="array" then
					(
					map(sub("^\t?";""))|
					map(select(test("^#")|not))|
					if first=="" then .[1:] else . end|
					if last=="" then .[0:-1] else . end
					)
				else . end
			;'

			# Compat, try to detect wrong usage
			if [ "$3" = "named" ] && [ -n "$4" ]; then
				echo >&2 "WARNING: $self $1 ... $3 ... ; possible wrong usage, it should be $self $1 ... :$3 ..."
			fi

			# Support ":function $CODE :named $NAME" like ":ifndef $NAME :function $CODE"
			if [ "${3#:}" = "named" ] && [ -n "$4" ]; then
				jq -ncM --arg arg1 "${1#:}" --arg arg2 "$2" --arg arg4 "$4" \
					"$funcdefclean"'{"name":$arg4,($arg1):($arg2|split("\n")|funcdefclean)}' >> "$JQ_STACK4_TMP"
				shift 3
			else
				jq -ncM --arg arg1 "${1#:}" --arg arg2 "$2" \
					"$funcdefclean"'{($arg1):($arg2|split("\n")|funcdefclean)}' >> "$JQ_STACK4_TMP"
				shift
			fi
		;;
		(:envfunction)
			local name="${2%%\(*}";shift
			local vname="$(printf '%s%s' "jq_function_" "$name")"

			# test if the function_def is available in env
			if ! eval "test -n \"\${$vname}\""; then
				echo >&2 "ERROR: function $vname not available in env"
			fi
			eval "${self} :function \"\${$vname}\" :named \"$name\"" >> "$JQ_STACK4_TMP"
		;;
		(:ifndef)
			# ifndef <name> function|envfunction ...
			case "$3" in
			(:function|:envfunction);;
			(*)
				echo >&2 "Syntax Error: must be: :ifndef ... :envfunction|:function ... got $3"
				return 1
			;;
			esac
			if [ "$(jq <"$JQ_STACK4_TMP" -cM --arg arg2 "$2" '[.,inputs]|any(select(.name==$arg2))')" = true ]; then
				shift 2
				if [ "$3" = ":named" ]; then
					shift 2
				fi
			fi
			shift
		;;
		(:cat)	[ ! -t 1 ] && cat -- "$JQ_STACK4_TMP" || jq -c . < "$JQ_STACK4_TMP";;
		(:gen)
			jq -sr '
			def tosh: map(if test("^[a-zA-Z0-9./=_-]+$") then . else @sh end)|join(" ");
			[	map(.option//empty)[],
				(	map(select(.function?)) | map(.function|join("\n")) |join("")
				) + (
					map(select(.call)|select(.call!="."))|
					to_entries|sort_by(if .value.pre then -.key else .key end)|
					map(.value.call)|join("|")
				)
			]|tosh
			' < "$JQ_STACK4_TMP"
		;;
		(:run)
			if [ "$2" = "-n" ]; then
				shift
				${self} :gen :deinit >&2
				return 0
			fi
			local eval="jq $(${self} :gen)"
			${self} :deinit
			eval "$eval"
		;;
		(:modload)
			shift
			local name="$1"
			local fname="jq_function_$name"
			if eval "test -z \"\${$fname}\""; then
				local dir="${JQ_STACK4_MODDIR:-.}"
				if [ ! -d "$dir" ]; then
					echo >&2 "No such dir $dir"
					return 1
				fi
				. "$dir/$name.jq.lib.sh"
				if ! eval "test -n \"\${$fname}\""; then
					echo >&2 "ERROR: $fname not available in env"
					return 1
				fi
			fi
			local dname="jq_deps_$name"
			if eval "test -n \"\${$dname}\""; then
				for dep in $(eval echo "\"\${$dname}\""); do
					$self :modload "$dep"
				done
			fi
			$self :ifndef "$name" :envfunction "$name"
		;;
		# 1 arg: "modname"
		# 1 arg: "modname(...)"
		(:modcall|:modprecall)
			local arg1="${1#:mod}";shift	# call|precall
			local arg2="$1";shift		# NAME(...)
			set -- :modload "${arg2%%\(*}" ":$arg1" "$arg2" "$@"
			#      :modload  NAME           :call    NAME(...)
			continue
		;;
		(*)
			if [ "${JQ_STACK4_FALLBACK:-false}" != true ]; then
				echo >&2 "ERROR: ${self}: fallback feature is disabled by default. Use \"$self :fallback\" before this action ($1) to enable it."
				return 1
			fi
			local cmd="${self}_${1#:}"
			if ! command >/dev/null 2>&1 -v "$cmd"; then
				echo >&2 "ERROR: ${self}: Invalid argument #1 $1";
				return 1
			fi
			shift
			"$cmd" "$@"
			return $?
		;;
		esac
		shift
	done
}
