
jq_stack() {
	case "$1" in
	(init)		jq_stack_options='';jq_stack_functions='';jq_stack_calls='.'	;;
	(run)		jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"	;;
	(call)		jq_stack_calls="$jq_stack_calls"'|'"$2"				;;
	(option)	jq_stack_options="$jq_stack_options $2"				;;
	(function)	jq_stack_functions="$jq_stack_functions$2"			;;
	(locals)	echo "jq_stack_options jq_stack_functions jq_stack_calls"	;;
	(*)		echo >&2 "ERROR: jq_stack: Invalid argument #1"; return 1	;;
	esac
}
