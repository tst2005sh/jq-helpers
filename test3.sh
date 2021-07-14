#!/bin/sh

. ./lib/jq_stack3.lib.sh
#. ./lib/jq_stack3_modcall.lib.sh
#. ./lib/jq_stack3_modload.lib.sh
#. ./lib/jq_stack3_oneline.lib.sh

export JQ_STACK3_MODDIR="../jsondiff/lib"


#jq -rc '["jq", .option, (.functiondef + .call)]|@sh'

#jqmod2jqargs() {
#	jq -rc '
#	[
#		"jq",
#		.option,
#		( (.functiondef|join("\n")) + .call )
#	]|@sh'
#}
test2a() {
	jq_stack3 init
	{
	echo '{"option": "-c"}'
	echo '{"name":"sortallarrays"}'
	echo '{"function": '"$(jq -cR . < test2-function-jq.def | jq -s .)"'}'
	echo '{"modload": "sortallarrays"}'
	echo '{"call":".|sortallarrays|."}'
	} > "$JQ_STACK3_TMP"
	jq_stack3 run
}

test1a() {
	jq_stack3 init
	jq_stack3 option -c
	jq_stack3 modload sortallarrays call '.|sortallarrays|.'
	#jq_stack3 cat
	#jq_stack3 gen
	jq_stack3 run
}
#test2b() {
#	jq_stack3 oneline -c sortallarrays: '.|sortallarrays|.'
#}

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test2a | checktest
#echo '["3", "1", "2"]' | test2b | checktest
echo '["3", "1", "2"]' | test1a | checktest

jq_stack3 deinit
