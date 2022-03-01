#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jsondiff/lib"

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
	jq_stack4 :init
	{
	echo '{"option": "-c"}'
	echo '{"name":"sortallarrays"}'
	echo '{"function": '"$(jq -cR . < test2-function-jq.def | jq -s .)"'}'
	echo '{"modload": "sortallarrays"}'
	echo '{"call":".|sortallarrays|."}'
	} > "$JQ_STACK4_TMP"
	jq_stack4 :run
	jq_stack4 :deinit
}

test1a() {
#	jq_stack4 :init
	jq_stack4 :option -c
	jq_stack4 :modload sortallarrays :call '.|sortallarrays|.'
	#jq_stack4 :cat
	#jq_stack4 :gen
	jq_stack4 :run
	jq_stack4 :deinit
}
#test2b() {
#	jq_stack4 :oneline -c sortallarrays: '.|sortallarrays|.'
#}

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test2a | checktest
#echo '["3", "1", "2"]' | test2b | checktest
echo '["3", "1", "2"]' | test1a | checktest

