
jq_stack2() {
	while [ $# -gt 0 ]; do
		case "$1" in
		(init)
		;;
		(locals)
			return 0
		;;
		(call|option)
			jq -ncM --arg arg1 "$1" --arg arg2 "$2" '{($arg1):$arg2}'
			shift
		;;
		(function)
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
				jq -ncM --arg arg1 "$1" --arg arg2 "$2" --arg arg4 "$4" "$funcdefclean"'{($arg1):($arg2|split("\n")|funcdefclean),"name":$arg4}'
				shift 3
			else
				jq -ncM --arg arg1 "$1" --arg arg2 "$2" "$funcdefclean"'{($arg1):($arg2|split("\n")|funcdefclean)}'
				shift
			fi
		;;
		(precall)
set -e;NIY_precall
		;;
		(envfunction)
			local name="${2%%\(*}";shift
			local vname="$(printf '%s%s' "jq_function_" "$name")"

			# test if the function_def is available in env
		        if ! eval "test -n \"\${$vname}\""; then
				echo >&2 "ERROR: function $vname not available in env"
		        fi
			#eval "jq_stack2 rawdef \"\${$vname}\""
			eval "jq_stack2 function \"\${$vname}\" named \"$name\""
		;;
		(rawdef)
set -e;NIY
			shift; set -- function "$@"; continue
		;;
		(ifndef)
			# ifndef <name> function ...
			if [ "$3" != function ]; then
				echo >&2 "Syntax Error: must be: ifndef ... function ... got $3 instead of function"
				return 1
			fi
			
#			jq -nc 	--arg a1 "$1" --arg a2 "$2" --arg a4 "$4" '{($a1): {name: $a2, function: $a4}}'
#			shift 3

			jq -ncM --arg arg1 "$1" --arg arg2 "$2" '{($arg1):$arg2}'
			shift
		;;
		(run)
			if [ "$2" = "-n" ]; then
				shift
			jq >&2 -sr '[	map(.option//empty)[],
					(	map(select(.function?)) | map(.function|join("\n")) |join("")
					) + (	map(.call//empty|select(.!="."))|join("|")
					)
				]|@sh
			'
				return 0
			fi
			jq -sr '[	map(.option//empty)[],
					(	map(select(.function?)) | map(.function|join("\n")) |join("")
					) + (	map(.call//empty|select(.!="."))|join("|")
					)
				]|@sh
			'
		;;
		(run_)
			if [ "$1" = "-n" ]; then
				shift
#				echo jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
#				echo --------------
#				echo "jq_stack_options=$jq_stack_options"
#				echo --------------
			else
#				jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
				echo '{"run": true}'
				return $?
			fi
		;;
		(*)
			if command >/dev/null 2>&1 -v "jq_stack2_$1"; then
				local cmd="jq_stack2_$1"; shift
				"$cmd" "$@"
				return $?
			fi
			echo >&2 "ERROR: jq_stack2: Invalid argument #1 $1";
			return 1
		;;
		esac
		shift
	done
}
