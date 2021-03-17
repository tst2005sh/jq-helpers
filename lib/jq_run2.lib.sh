
jq_run2_with_prefix() {
	eval "jq $(
	{
	for var in $(jq_stack2 locals); do local "$var"; done
	local prefix="$1";shift
	jq_stack2 init
	for cmd in "$@"; do
		"$prefix$cmd"
	done
	} | jq_stack2 run
	)"
}
jq_run2() {
	jq_run2_with_prefix jq_cmd2_ "$@"
}
