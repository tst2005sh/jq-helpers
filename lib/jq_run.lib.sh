
jq_run_with_prefix() {
	for var in $(jq_stack locals); do local "$var"; done
	#local jq__stack_functions jq_stack_options jq_stack_calls
	local prefix="$1";shift
	jq_stack init
	for cmd in "$@"; do
		"$prefix$cmd"
	done
	jq_stack run
}
jq_run() {
	jq_run_with_prefix jq_cmd_ "$@"
}
