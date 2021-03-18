

jq_gen2_with_prefix() {
	{
	for var in $(jq_stack2 locals); do local "$var"; done
	local prefix="$1";shift
	jq_stack2 init
	for cmd in "$@"; do
		"$prefix$cmd"
	done
	} | jq_stack2 run
}

jq_run2_with_prefix() {
	eval "jq $(jq_gen2_with_prefix "$@")"
}
jq_run2() {
	jq_run2_with_prefix jq_cmd2_ "$@"
}
jq_gen2() {
	jq_gen2_with_prefix jq_cmd2_ "$@"
}
