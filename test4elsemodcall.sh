#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jsondiff/lib"

test3() {
	jq_option_foo='-r'
	jq_function_foo='def foo: "ok";'

	jq_stack4 :else modcall
	jq_stack4 -n 'foo' -s
	jq_stack4 :gen :deinit
}

test3; exit
