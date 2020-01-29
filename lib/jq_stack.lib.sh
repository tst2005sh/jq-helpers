
jq_stack() {
	while [ $# -gt 0 ]; do
		case "$1" in
		(init)
			jq_stack_options='';jq_stack_functions='';jq_stack_calls=''
		;;
		(call)
			if [ -z "$jq_stack_calls" ]; then
				jq_stack_calls="$2";shift
			else
				jq_stack_calls="$jq_stack_calls"'|'"$2";shift
			fi
		;;
		(option)
			jq_stack_options="$jq_stack_options $2";shift
		;;
		(function)
			jq_stack_functions="$jq_stack_functions$2";shift
		;;
		(locals)
			echo "jq_stack_options jq_stack_functions jq_stack_calls"
			return 0
		;;
		(run)
			jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
			return $?
		;;
		(*)
			echo >&2 "ERROR: jq_stack: Invalid argument #1";
			return 1
		;;
		esac
		shift
	done
}
