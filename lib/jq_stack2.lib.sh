
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
		(precall|envfunction)
set -e;NIY
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
			jq -sr '[	map(.option//empty)[],
					(	map(select(.function?)) | map(.function|join("\n")) |join("")
					) + (	map(.call//empty|select(.!="."))|join("|")
					)
				]|@sh
			'
		;;
		(run_)
			shift
			if [ "$1" = "-n" ]; then
#				echo jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
#				echo --------------
#				echo "jq_stack_options=$jq_stack_options"
#				echo --------------
# ERROR ici ?			shift
:
			else
#				jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
				echo '{"run": true}'
				return $?
			fi
		;;
		(*)
echo "NIY: $1"
exit 1
			if command >/dev/null 2>&1 -v "jq_stack_$1"; then
				local cmd="jq_stack_$1"; shift
				"$cmd" "$@"
				return $?
			fi
			echo >&2 "ERROR: jq_stack: Invalid argument #1";
			return 1
		;;
		esac
		shift
	done
}
