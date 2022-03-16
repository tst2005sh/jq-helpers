#!/bin/sh

. ./lib/jq_stack4.lib.sh

test_opt_args_a() {
	jq_stack4 -c
	jq_stack4 -Lfoo
	jq_stack4 -s

	#jq_stack4 :cat
	[ "$(jq_stack4 :gen)" = "-c -L foo -s ''" ] &&
	echo ok || echo fail

	#jq_stack4 :run
	jq_stack4 :deinit
}
test_opt_args_b() {
	jq_stack4 -c
	jq_stack4 :option -L :option foo
	jq_stack4 -s

	#jq_stack4 :cat
	[ "$(jq_stack4 :gen)" = "-c -L foo -s ''" ] &&
	echo ok || echo fail

	#jq_stack4 :run
	jq_stack4 :deinit
}
test_opt_args_c() {
	jq_stack4 :option:2arg --arg a "ok"
	#jq_stack4 :cat
	#jq_stack4 :gen
	jq_stack4 -n -r :call '$a'
	jq_stack4 :run
	#jq_stack4 :deinit
}


test_opt_args_a
test_opt_args_b
test_opt_args_c
