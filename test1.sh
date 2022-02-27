#!/bin/sh

. ./lib/jq_stack1.lib.sh
. ./lib/jq_stack1_modcall.lib.sh
. ./lib/jq_stack1_modload.lib.sh
. ./lib/jq_stack1_oneline.lib.sh

export JQ_STACK_MODDIR="../jsondiff/lib"

test1() {
	jq_stack1 init
	jq_stack1 option -c
	jq_stack1 modcall sortallarrays '.|sortallarrays|.'
	jq_stack1 run
}

test2() {
	jq_stack1 oneline -c sortallarrays: '.|sortallarrays|.'
}

if false; then
jq() {
	echo >&2 "jq call with $# arg(s)"
	for x in "$@"; do
		echo >&2 "$x"
		echo >&2 "------------"
	done
	command -p jq "$@"
}
fi

checktest() {
	read result;
	[ "$result" = '["1","2","3"]' ] && echo ok || echo fail
}

echo '["3", "1", "2"]' | test1 | checktest
echo '["3", "1", "2"]' | test2 | checktest
