#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jsondiff/lib"

test3() {
	jq_option_foo='-r'
	jq_function_foo='def foo: "ok";'

#	jq_stack4 :init
	jq_stack4 :else call
	jq_stack4 -n 'foo' -r
	jq_stack4 :modload foo
	jq_stack4 :run :deinit
}

test3; exit

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test1c | checktest
[ "$(test1d)" = 'ok' ] && echo ok || echo fail

