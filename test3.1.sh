
. ./lib/jq_stack3.lib.sh
#. ./lib/jq_stack3_modload.lib.sh
#. ./lib/jq_stack3_modcall.lib.sh

jq_stack3 init

jq_stack3 call "aa"
jq_stack3 call "bb"
jq_stack3 call "cc"
echo '{"misc":"bar"}' >> "$JQ_STACK3_TMP"
jq_stack3 precall "p1"
jq_stack3 precall "p2"
jq_stack3 call "dd"

[ "$(jq_stack3 gen)" = "'p2|p1|aa|bb|cc|dd'" ] && echo ok || echo fail
jq_stack3 deinit
