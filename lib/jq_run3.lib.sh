
jq_gen3_with_prefix() {
	local prefix="$1";shift
	jq_stack3 init
	for cmd in "$@"; do
		"$prefix$cmd"
	done
	jq_stack3 gen
}
jq_gen3() {
	jq_gen3_with_prefix jq_cmd3_ "$@"
}
jq_run3() {
	if [ "$1" = "-n" ]; then
		shift
		echo >&2 "jq $(jq_gen3 "$@")"
	else
		eval "jq $(jq_gen3 "$@")"
	fi
}
