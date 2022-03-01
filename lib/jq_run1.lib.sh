
jq_run1_with_prefix() {
	for var in $(jq_stack1 locals); do local "$var"; done
	#local jq_stack_functions jq_stack_options jq_stack_calls
	local prefix="$1";shift
	jq_stack1 init
	for cmd in "$@"; do
		"$prefix$cmd"
	done
	jq_stack1 run
}
jq_run1() {
	jq_run1_with_prefix jq_cmd1_ "$@"
}
