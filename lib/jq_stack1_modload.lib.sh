jq_stack_modload() {
	local fname="$1";shift
	local vname="jq_function_$fname"
	local dir="${JQ_STACK_MODDIR:-.}"
	if [ ! -d "$dir" ]; then
		echo >&2 "No such dir $dir"
		return 1
	fi
	. "$dir/$fname.jq.lib.sh"
	if ! eval "test -n \"\${$vname}\""; then
		echo >&2 "ERROR: $vname not available in env"
		return 1
	fi
}

#FIXME: rename jq.*.lib.sh to jq.*.mod.sh ? or jq.function.*.lib.sh ?
