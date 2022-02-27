# 1 arg: "modname"
# 1 arg: "modname(...)"
# 2 arg: "modname" "custom|modname(...)|code"
jq_stack1_modcall() {
	# extract only the modname (without parentesis/arguments)
	local name="${1%%\(*}"
	local vname="$(printf '%s%s' "jq_function_" "$name")"

	# test if the function_def is available in env
	if ! eval "test -n \"\${$vname}\""; then
		jq_stack1 modload "$name" "$vname" || return $?
	fi
	eval "jq_stack1 ifndef \"\$name\" function \"\${$vname}\""
	jq_stack1 call "${2:-$1}"
}
#bug FIXME: multiple call of the same mod load multiple function_def
