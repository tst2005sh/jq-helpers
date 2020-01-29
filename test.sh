#!/bin/sh

. ./lib/jq_stack.lib.sh
. ./lib/jq_stack_modcall.lib.sh
. ./lib/jq_stack_modload.lib.sh
. ./lib/jq_stack_envfunction.lib.sh
. ./lib/jq_stack_oneline.lib.sh

export JQ_STACK_MODDIR="../jsondiff/lib"

test1() {
	jq_stack init
	jq_stack option -c
	jq_stack modcall sortallarrays '.|sortallarrays|.'
	jq_stack run
}

test1() {
	jq_stack oneline -c sortallarrays: '.|sortallarrays|.'
}

jq() {
	echo >&2 "jq call with $# arg(s)"
	for x in "$@"; do
		echo >&2 "$x"
		echo >&2 "------------"
	done
	command -p jq "$@"
}


checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test1 | checktest
