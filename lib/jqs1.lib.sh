if [ -z "$JQS" ]; then
	echo >&2 "Please load jqs.lib.sh with :"
	echo >&2 '   eval "$(/path/to/jq-helpers/bin/load_jq_stack1.sh)"'
	false
else
. "${JQS%/*}/jq_stack1.lib.sh"
. "${JQS%/*}/jq_stack1_modcall.lib.sh"
. "${JQS%/*}/jq_stack1_modload.lib.sh"
. "${JQS%/*}/jq_stack1_oneline.lib.sh"
fi
