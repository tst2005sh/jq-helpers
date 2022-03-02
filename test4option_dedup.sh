#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jsondiff/lib"

test_opt_dedup() {
	jq_stack4 :option -C
	jq_stack4 :option -M
	jq_stack4 :option -C

	jq_stack4 :cat
	jq_stack4 :gen

	#jq_stack4 :run
	jq_stack4 :deinit
}

test_opt_split() {
	jq_stack4 :init
	jq_stack4 -scMr

	jq_stack4 :cat
	jq_stack4 :gen

	#jq_stack4 :run
	jq_stack4 :deinit
}

test_opt_dedup
test_opt_split
