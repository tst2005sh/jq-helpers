#!/bin/sh

. ./lib/jq_stack2.lib.sh
. ./lib/jq_stack2_modcall.lib.sh
. ./lib/jq_stack2_modload.lib.sh
. ./lib/jq_stack2_oneline.lib.sh

export JQ_STACK2_MODDIR="../jsondiff/lib"


#jq -rc '["jq", .option, (.functiondef + .call)]|@sh'

jqmod2jqargs() {
	jq -rc '
	[
		"jq",
		.option,
		( (.functiondef|join("\n")) + .call )
	]|@sh'
}
test2a_() {
	{
	echo '{"option": "-c"}'
	echo '{"name":"sortallarrays"}'
	echo '{"function": '"$(jq -cR . < test2-function-jq.def | jq -s .)"'}'
	echo '{"modload": "sortallarrays"}'
	echo '{"call":".|sortallarrays|."}'
	} | jq_stack2 run
}
test2a() {
	eval "jq $(test2a_)"
}

test1a() {
	jq_stack init
	jq_stack option -c
	jq_stack modcall sortallarrays '.|sortallarrays|.'
	jq_stack run
}
test2b() {
	jq_stack2 oneline -c sortallarrays: '.|sortallarrays|.'
}

test1b() {
	jq_stack oneline -c sortallarrays: '.|sortallarrays|.'
}

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test2a | checktest
echo '["3", "1", "2"]' | test2b | checktest
