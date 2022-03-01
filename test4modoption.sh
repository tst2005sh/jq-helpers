#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jsondiff/lib"

test1c() {
#	jq_stack4 :init
#	jq_stack4 :option -c
	jq_stack4 :modload sortallarrays :call '.|sortallarrays|.'
	jq_stack4 :modoption sortallarrays
	#jq_stack4 :cat
	#jq_stack4 :gen
	jq_stack4 :run
}
test1d() {
	jq_option_foo='-r'
	jq_function_foo='def foo: "ok";'
#	jq_stack4 :init
	jq_stack4 :option -n
	jq_stack4 :modcall foo
	jq_stack4 :run
}
test1e() {
	jq_option_foo='-r'
	jq_function_foo='def foo: "ok";'
#	jq_stack4 :init
	jq_stack4 -n
	jq_stack4 --arg "fo o" "FOO BAR"
	jq_stack4 :modcall foo
	jq_stack4 :gen :deinit
}

#test1e; exit

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test1c | checktest
[ "$(test1d)" = 'ok' ] && echo ok || echo fail

