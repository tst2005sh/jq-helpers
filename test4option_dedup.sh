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
}

test_opt_dedup
