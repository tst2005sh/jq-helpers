jq_stack3_modload() {
	local fname="$1";shift
	local vname="jq_function_$fname"
	local dir="${JQ_STACK3_MODDIR:-.}"
	if [ ! -d "$dir" ]; then
		echo >&2 "No such dir $dir"
		return 1
	fi
	. "$dir/$fname.jq.lib.sh"
	if ! eval "test -n \"\${$vname}\""; then
                echo >&2 "ERROR: $vname not available in env"
		return 1
	fi
	local dname="jq_deps_$fname"
	if eval "test -n \"\${$dname}\""; then
		for dep in $(eval echo "\"\${$dname}\""); do
			echo >&2 "deps: $dep"
		        #jq_stack2 ifndef "$deps" modload "$deps"
		done
	fi
}

