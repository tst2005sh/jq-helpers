# 1 arg: "modname"
# 1 arg: "modname(...)" # ignore (...)
jq_stack_envfunction() {
	# extract only the modname (without parentesis/arguments)
        local vname="$(printf '%s%s' "jq_function_" "${1%%(*}")"

	# test if the function_def is available in env
        if ! eval "test -n \"\${$vname}\""; then
		echo >&2 "ERROR: function $vname not available in env"
		#jq_stack modload "${1%%(*}" "$vname" || return $?
        fi
	eval "jq_stack function \"\${$vname}\""
}
#bug FIXME: multiple call of the same mod load multiple function_def
