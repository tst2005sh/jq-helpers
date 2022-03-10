
jq_stack4() {
	local self=jq_stack4
	while [ $# -gt 0 ]; do
		case "$1" in
		(--help|-h) $self :help;return 0;;
		(:help)
			{
			echo "Usage: $self [<option>]|<command [argument]>"
			echo ''
			echo 'Behavior commands and argument values:'
			echo '  :else call|external|error|modcall (default: error)'
			echo '  :with|:without autoinit|external|shorter-option'
			echo ''
			echo 'High level command:'
			echo '  :modload    <modname>        -- Find and load the <modname> module'
			echo '  :modoption  <modname>        -- equals to :option: $jq_option_<modname>'
			echo '  :modcall    <modname(*)>     -- equals to :moadload ... :modoption ... :call ...'
			echo '  :modprecall <modname(*)>     -- equals to :moadload ... :modoption ... :precall ...'
			echo ''
			echo 'Common command:'
			echo '  :init                        -- '
			echo '  :call    <jq-code>           -- '
			echo '  :precall <jq-code>           -- '
			echo '  :run [-n]                    -- '
			echo '  :deinit                      -- '
			echo ''
			echo 'Low level command:'
			echo '  :option <rawvalue>           -- '
			echo '  :option: <valid-option>      -- '
			echo '  :function F :named N         -- '
			echo '  :envfunction E'
			echo '  :ifndef <name> :function|:envfunction ...'
			echo '  :option:0arg'
			echo '  :option:1arg'
			echo '  :option:2arg'
			echo '  :cat                         -- for debug purpose: dump the stacked JSON content'
			echo '  :gen                         -- render the stacked content to jq arguments'
			echo ''
			echo 'defaults behavior:'
			echo '  :else error  :with autoinit  :with shorter-option  :without external'
			} >&2
			#echo "debug: $#: $*"
			return 0
		;;
		(:else)
			shift
			case "$1" in
			(call|external|error|modcall) JQ_STACK4_ELSE="$1" ;;
			(*)
				echo >&2 "ERROR: $self: unknown value for :else argument. Expected: call|external|error|modcall, got: $1"
				return 1
			;;
			esac
			shift; continue
		;;
		(:with|:without)
			local v
			case "$1" in
			(:with) v=true;;
			(:without) v=false;;
			esac

			shift
			case "$1" in
			(autoinit) JQ_STACK4_AUTOINIT=$v ;;
			(external) JQ_STACK4_EXTERNAL=$v ;;
			(shorter-option) JQ_STACK4_SHORTEROPTION=$v;;
			(*)
				echo >&2 "ERROR: $self: unknown argument for :with/:without command. Expected: autoinit|external|shorter-option, got: $1"
				return 1
			;;
			esac
			shift; continue
		;;
		esac

		case "$1" in
		(:init)
			JQ_STACK4_TMP="$(mktemp -q /dev/shm/$self.tmp.XXXXXXXX || mktemp /tmp/$self.tmp.XXXXXXXX)" || return 1
			false
		;;
		(:deinit)
			[ -z "$JQ_STACK4_TMP" ] || [ ! -f "$JQ_STACK4_TMP" ] || rm -f "$JQ_STACK4_TMP" >&2
			false
		;;
		esac || { shift; continue; }

		if [ -z "$JQ_STACK4_TMP" ] || [ ! -f "$JQ_STACK4_TMP" ]; then
			if [ "${JQ_STACK4_AUTOINIT:-true}" != true ]; then
				echo >&2 "ERROR: ${self}: not initialized (auto init is disabled). Use \"$self :init\" before this action (or enable auto init with \"$self :with autoinit\")"
				return 1
			fi
			# autoinit
			$self :init
		fi

		case "$1" in
		(-[sRncCMaSrje][sRncCMaSrje]*)
			# Split concatenated short options: -xyz to -x -yz (and the next loop will split -yz to -y -z)
			local opt1="$(printf %.2s "$1")"
			local opts="-${1#-?}"
			shift
			set -- "$opt1" "$opts" "$@"
			continue
		;;
		(-*) set -- :option: "$@";;
		esac

		case "$1" in
		(:option:)
			shift
			if [ "${JQ_STACK4_SHORTEROPTION:-true}" = true ]; then
				local a=''
				case "$1" in
				(--color-output|--monochrome-output|--sort-keys)
					a="$(printf %.1s "${1#--}"|tr a-z A-Z)";false;;
				(--ascii-output|--compact-output|--exit-status|--from-file|--join-output|--null-input|--raw-output|--slurp)
					a="$(printf %.1s "${1#--}")";false;;
				esac || { shift; set -- "-$a" "$@"; }
			fi
			case "$1" in
			(-[CM]|--color-output|--monochrome-output)
				# -M will disable the color, even if -C is use after (no need to remind who is use the last)
				$self :option:0arg "$1"
			;;
			(-[sRncaSrje]|--version|--seq|--stream|--slurp|--raw-input|--null-input|--compact-output|--tab|--ascii-output|--unbuffered|--sort-keys|--raw-output|--join-output|--exit-status)
				$self :option:0arg "$1"
			;;
			(-L?*) # split "-Ldirectory" (1 arg) to "-L" "directory" (2 arg)
				local opt="$1";shift
				set -- "-L" "${opt#-L}" "$@"
				continue
			;;
			(--indent|--from-file|-f|-L) # 1 arg
				$self :option:1arg "$1" "$2"
				shift 1
			;;
			(--arg|--argjson|--slurpfile|--argfile) # 2 args
				$self :option:2arg "$1" "$2" "$3"
				shift 2
			;;
			(--run-tests)
				echo >&2 "ERROR: $self: this option will not be supported due to its complexity and positional constraint. Please use jq directly."
				return 1
			;;
			(--|--*|-*|*)
				echo >&2 "ERROR: $self does not known this jq option ($1)"
				return 1
			;;
			esac
		;;
		(:call|:option)
			local k="${1#:}"; shift
			jq -ncM --arg k "$k" --arg opt "$1" '{($k):$opt}' >> "$JQ_STACK4_TMP"
		;;
		(:option:0arg)
			local k="${1#:}"; k="${k%%:*}"; shift
			jq -ncM --arg k "$k" --arg opt "$1" '{($k):$opt}' >> "$JQ_STACK4_TMP"
		;;
		(:option:1arg)
			shift
			jq -ncM --arg k "option" --arg opt "$1" --arg arg1 "$2" '{($k):[$opt,$arg1]}' >> "$JQ_STACK4_TMP"
			shift 1
		;;
		(:option:2arg)
			shift
			jq -ncM --arg k "option" --arg opt "$1" --arg arg1 "$2" '{($k):[$opt,$arg1,$arg2]}' >> "$JQ_STACK4_TMP"
			shift 2
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
			def merge_consecutive_short_options:
				map(if type=="string" and ( (startswith("-")|not) or (startswith("--") or startswith("-L")) ) then [.] else . end)|
				reduce .[] as $i ([]; (.[-1]+=($i |sub("^-";"")) )? // .+=[ $i ])
			;
			def options_dedup(r): map(.option//empty)|r|unique_no_sort_by(@sh)|r|merge_consecutive_short_options|flatten;
			# options_dedup(.) will keep the first option use
			# options_dedup(reverse) will keep the last option use
			[	(options_dedup(reverse)[]),
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
				set -- "$o" "$@"
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
		(:*)
			if [ "${JQ_STACK4_EXTERNAL:-false}" != true ]; then
				echo >&2 "ERROR: ${self}: external commands are disabled by default. Use \"$self :with external\" before this action ($1) to enable it."
				return 1
			fi
			local cmd="jq_cmd${self#jq_stack}_${1#:}" # jq_stack4 :foo should call the shell function jq_cmd4_foo
			if ! command >/dev/null 2>&1 -v "$cmd"; then
				echo >&2 "ERROR: ${self}: Invalid command $1";
				return 1
			fi
			shift
			"$cmd" "$@" || return 1
			continue
		;;
		(*)
			case "${JQ_STACK4_ELSE:-error}" in
			(error)
				echo >&2 "ERROR: ${self}: unknown command/option ($1). Please configure the behavior (currently: $self :else error). Use \"$self :else call\" to add $1 like \"$self :call $1\" or Use \"$self :else external\" to mimic \"$self :$1\" maybe for jq_stack3 compat (See also :with external)"
				return 1
			;;
			(call|modcall) set -- ":${JQ_STACK4_ELSE}" "$@"; continue;;
			(external) set -- ":$@"; continue;;
			esac
		;;
		esac
		shift
	done
}
