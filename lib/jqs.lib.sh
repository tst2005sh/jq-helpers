if [ -z "$JQS" ]; then
	echo >&2 "Please load jqs.lib.sh with :"
	echo >&2 '   eval "$(/path/to/jq-helpers/bin/load_jq_stack.sh)"'
	false
else
. "${JQS%/*}/jq_stack.lib.sh"
. "${JQS%/*}/jq_stack_modcall.lib.sh"
. "${JQS%/*}/jq_stack_modload.lib.sh"
. "${JQS%/*}/jq_stack_oneline.lib.sh"
fi
