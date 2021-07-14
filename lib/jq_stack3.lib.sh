
jq_stack3() {
	local self=jq_stack3
	while [ $# -gt 0 ]; do
		case "$1" in
		(init)
			JQ_STACK3_TMP="$(TMPDIR=/dev/shm mktemp -q || mktemp)" || return 1
			shift;continue
		;;
		(locals)
			return 0
		;;
		(deinit)
			[ -z "$JQ_STACK3_TMP" ] || [ ! -f "$JQ_STACK3_TMP" ] || rm -f "$JQ_STACK3_TMP" >&2
			shift;continue
		;;
		esac
		if [ -z "$JQ_STACK3_TMP" ] || [ ! -f "$JQ_STACK3_TMP" ]; then
			echo >&2 "ERROR: ${self}: not initialized. Please use $self init"
			return 1
		fi
		case "$1" in
		(call|option)
			jq -ncM --arg arg1 "$1" --arg arg2 "$2" '{($arg1):$arg2}' >> "$JQ_STACK3_TMP"
			shift
		;;
		(precall)
			jq -ncM --arg arg1 "call" --arg arg2 "$2" '{($arg1):$arg2,"pre":true}' >> "$JQ_STACK3_TMP"
			shift
		;;
		(function|rawdef)
			if [ "$1" = rawdef ]; then
				shift; set -- function "$@"
			fi
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
			if [ "$3" = "named" ] && [ -n "$4" ]; then
				jq -ncM --arg arg1 "$1" --arg arg2 "$2" --arg arg4 "$4" \
					"$funcdefclean"'{"name":$arg4,($arg1):($arg2|split("\n")|funcdefclean)}' >> "$JQ_STACK3_TMP"
				shift 3
			else
				jq -ncM --arg arg1 "$1" --arg arg2 "$2" \
					"$funcdefclean"'{($arg1):($arg2|split("\n")|funcdefclean)}' >> "$JQ_STACK3_TMP"
				shift
			fi
		;;
		(envfunction)
			local name="${2%%\(*}";shift
			local vname="$(printf '%s%s' "jq_function_" "$name")"

			# test if the function_def is available in env
			if ! eval "test -n \"\${$vname}\""; then
				echo >&2 "ERROR: function $vname not available in env"
			fi
			eval "${self} function \"\${$vname}\" named \"$name\"" >> "$JQ_STACK3_TMP"
		;;
		(ifndef)
			# ifndef <name> function|envfunction ...
			case "$3" in
			(function|envfunction);;
			(*)
				echo >&2 "Syntax Error: must be: ifndef ... envfunction|function ... got $3"
				return 1
			;;
			esac
			if [ "$(jq <"$JQ_STACK3_TMP" -cM --arg arg2 "$2" '[.,inputs]|any(select(.name==$arg2))')" = true ]; then
				#jq -ncM --arg arg1 "$1" --arg arg2 "$2" '{($arg1):$arg2}' >> "$JQ_STACK3_TMP"
				shift 2
				if [ "$3" = named ]; then
					echo >&2 "$2 already defined: skip $1 $2 $3 $4"
					shift 2
				else
					echo >&2 "$2 already defined: skip $1 $2"

				fi
			fi
			shift
		;;
		(cat)	[ ! -t 1 ] && cat -- "$JQ_STACK3_TMP" || jq -c . < "$JQ_STACK3_TMP";;
		(gen)
			jq -sr '
			[	map(.option//empty)[],
				(	map(select(.function?)) | map(.function|join("\n")) |join("")
				) + (	map(.call//empty|select(.!="."))|join("|")
				)
			]|@sh
			' < "$JQ_STACK3_TMP"
		;;
		(run)
			if [ "$2" = "-n" ]; then
				shift
				${self} gen >&2
				return 0
			fi
			local eval="jq $(${self} gen)"
			${self} deinit
			eval "$eval"
		;;
		(*)
			local cmd="${self}_$1"
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
