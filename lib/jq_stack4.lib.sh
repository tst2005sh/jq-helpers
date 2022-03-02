
jq_stack4() {
	local self=jq_stack4
	while [ $# -gt 0 ]; do
		case "$1" in
		(:rawdef)	echo >&2 "DEPRECATED; Use $self :function instead of $self :rawdef"; return 1;;
		(:locals)	echo >&2 "DEPRECATED"; return 1;;
#		(:rawdef)	shift; set -- :function "$@";;
#		(:locals)	return 0;;
		esac

		case "$1" in
		(:autoinit)	JQ_STACK4_AUTOINIT=true ;shift;continue;;
		(:noautoinit)	JQ_STACK4_AUTOINIT=false;shift;continue;;
		(:external)	JQ_STACK4_EXTERNAL=true ;shift;continue;;
		(:noexternal)	JQ_STACK4_EXTERNAL=false;shift;continue;;
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
			# autoinit
			$self :init
		fi

		case "$1" in
		(-[sRncCMaSrje]|--version|--seq|--stream|--slurp|--raw-input|--null-input|--compact-output|--tab|--color-output|--monochrome-output|--ascii-output|--unbuffered|--sort-keys|--raw-output|--join-output|--exit-status)
			$self :option "$1"
		;;
		(--indent|-f|--from-file|-L) # 1 arg
			$self :option. "$1" "$2"
			shift 1
		;;
		(--arg|--argjson|--slurpfile|--argfile) # 2 args
			$self :option.. "$1" "$2" "$3"
			shift 2
		;;
		# (--) TODO? ;;
		(-*)
			echo >&2 "ERROR: $self does not known this jq option ($1)"
			return 1
		;;
		(:option.)
			shift
			jq -ncM --arg arg1 "$1" --arg arg2 "$2" '{"option":[$arg1,$arg2]}' >> "$JQ_STACK4_TMP"
			shift 1
		;;
		(:option..)
			shift
			jq -ncM --arg arg1 "$1" --arg arg2 "$2" --arg arg3 "$3" '{"option":[$arg1,$arg2,$arg3]}' >> "$JQ_STACK4_TMP"
			shift 2
		;;
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
			def unique_no_sort_by(f): to_entries|unique_by(.value|f)|sort_by(.key)|map(.value);
			[	(map(.option//empty)|unique_no_sort_by(@sh)|flatten[]),
				(	map(select(.function?)) | map(.function|join("\n")) |join("")
				) + (
					map(select(.call?)|select(.call!="."))|
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
		(:modoption)
			shift
			local name="$1"
			local fname="jq_option_$name"
			if eval "test -n \"\${$fname}\""; then
				local o
				eval "o=\"\${$fname}\""
				shift
				set -- :option "$o" "$@"
				continue
			fi
		;;
		# 1 arg: "modname"
		# 1 arg: "modname(...)"
		(:modcall|:modprecall)
			local cmd="${1#:mod}";shift	# call|precall
			local code="$1";shift		# NAME(...)
			local name="${code%%\(*}"	# NAME
			set -- :modload "$name" :modoption "$name" ":$cmd" "$code" "$@"
			continue
		;;
		(:autocall) JQ_STACK4_AUTOCALL=true;;
		(:noautocall) JQ_STACK4_AUTOCALL=false;;
		(:*)
			if [ "${JQ_STACK4_EXTERNAL:-false}" != true ]; then
				echo >&2 "ERROR: ${self}: external commands are disabled by default. Use \"$self :external\" before this action ($1) to enable it."
				return 1
			fi
			local cmd="jq_cmd${self#jq_stack}_${1#:}" # jq_stack4 :foo should call the shell function jq_cmd4_foo
			if ! command >/dev/null 2>&1 -v "$cmd"; then
				echo >&2 "ERROR: ${self}: Invalid command $1";
				return 1
			fi
			shift
			"$cmd" "$@"
			return $?
		;;
		(*)
			if [ "${JQ_STACK4_AUTOCALL:-false}" != true ]; then
				echo >&2 "ERROR: ${self}: autocall are disabled. Use \"$self :autocall\" before this action to enable it."
				return 1
			fi
			$self :call "$1"
		;;
		esac
		shift
	done
}
