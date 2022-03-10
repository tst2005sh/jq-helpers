#!/bin/sh

. ./lib/jq_stack4.lib.sh
. ./lib/jq_stack4compat3.lib.sh

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
	} > "$JQ_STACK4_TMP"
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

test4compat3() {
	[ "$(jq_stack3 2>/dev/null init locals rawdef foo 'def foo: .;' call foo gen deinit)" = "'def foo: .;foo'" ] && echo ok || echo fail
}

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test2a | checktest
#echo '["3", "1", "2"]' | test2b | checktest
echo '["3", "1", "2"]' | test1a | checktest

test4compat3

jq_stack3 deinit
