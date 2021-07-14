jq_stack3_modload() {
	local name="$1";shift
	local fname="jq_function_$name"
	local dir="${JQ_STACK3_MODDIR:-.}"
	if [ ! -d "$dir" ]; then
		echo >&2 "No such dir $dir"
		return 1
	fi
	. "$dir/$name.jq.lib.sh"
	if ! eval "test -n \"\${$fname}\""; then
		echo >&2 "ERROR: $fname not available in env"
		return 1
	fi
	local dname="jq_deps_$name"
	if eval "test -n \"\${$dname}\""; then
		for dep in $(eval echo "\"\${$dname}\""); do
			echo >&2 "deps: $dep"
			jq_stack3 modload "$dep"
		done
	fi
	jq_stack3 ifndef "$name" envfunction "$name"
}

