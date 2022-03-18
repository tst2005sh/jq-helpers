#!/bin/sh

. ./lib/jq_stack4.lib.sh

test_files_a() {
	jq_stack4 -R :call 'tostring'
	jq_stack4 :file "./a a/a.json"
	jq_stack4 :file "/b/b.json"
	[ "$(jq_stack4 :gen)" = "-R tostring './a a/a.json' /b/b.json" ] &&
	echo ok || echo fail

	#jq_stack4 :run
	jq_stack4 :deinit
}

test_files_a
