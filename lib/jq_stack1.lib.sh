
jq_stack1() {
	while [ $# -gt 0 ]; do
		case "$1" in
		(init)
			jq_stack_options='';jq_stack_functions='';jq_stack_functions_loaded='';jq_stack_calls=''
		;;
		(call)
			if [ -z "$jq_stack_calls" ]; then
				jq_stack_calls="$2";shift
			else
				jq_stack_calls="$jq_stack_calls"'|'"$2";shift
			fi
		;;
		(precall)
			if [ -z "$jq_stack_calls" ]; then
				jq_stack_calls="$2";shift
			else
				jq_stack_calls="$2"'|'"$jq_stack_calls";shift
			fi
		;;
		(option)
			jq_stack_options="$jq_stack_options $2";shift
		;;
		(function|rawdef)
			jq_stack_functions="$jq_stack_functions$2";shift
			if [ "$2" = "named" ]; then shift 2; fi
		;;
		(envfunction)
			local name="${2%%\(*}";shift
			local vname="$(printf '%s%s' "jq_function_" "$name")"

			# test if the function_def is available in env
			if ! eval "test -n \"\${$vname}\""; then
				echo >&2 "ERROR: function $vname not available in env"
			fi
			eval "jq_stack1 rawdef \"\${$vname}\""
		;;
		(ifndef)
			# ifndef <name> function ...
			if [ "$3" != function ]; then
				echo >&2 "Syntax Error: must be: ifndef ... function ... got $3 instead of function"
				return 1
			fi
			if case ":$jq_stack_functions_defined:" in
				(*:"$2":*) false;;
				(*) true ;;
			esac; then
				jq_stack_functions_defined="${jq_stack_functions_defined}:$2"
				shift
			else	# already defined, skip the next function+value
				shift 3
			fi
		;;
		(locals)
			echo "jq_stack_options jq_stack_functions jq_stack_functions_defined jq_stack_calls"
			return 0
		;;
		(run)
			if [ "$2" = "-n" ]; then
				shift
				echo jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
				echo --------------
				echo "jq_stack_options=$jq_stack_options"
				echo --------------
				#return 0
			else
				jq $jq_stack_options "$jq_stack_functions$jq_stack_calls"
				return $?
			fi
		;;
		(*)
			if command >/dev/null 2>&1 -v "jq_stack1_$1"; then
				local cmd="jq_stack1_$1"; shift
				"$cmd" "$@"
				return $?
			fi
			echo >&2 "ERROR: jq_stack1: Invalid argument #1";
			return 1
		;;
		esac
		shift
	done
}
