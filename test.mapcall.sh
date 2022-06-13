#!/bin/sh

. ./lib/jq_stack4.lib.sh

export JQ_STACK4_MODDIR="../jq-mods/lib"

test1() {

	jq_stack4 :call f4
	jq_stack4 :call f5
	jq_stack4 :mapcall f6
	jq_stack4 :mapcall f7

	jq_stack4 :premapcall f3
	jq_stack4 :precall f2

	jq_stack4 :call f8
	jq_stack4 :call f9
	jq_stack4 :mapcall f10

	jq_stack4 :precall f1

	jq_stack4 :gen
	jq_stack4 :deinit
}

checktest() {
	read result;
	[ "$result" = "$1" ] && echo ok || echo fail
}

test1 | checktest "'f1|f2|map(f3)|f4|f5|map(f6|f7)|f8|f9|map(f10)'"
