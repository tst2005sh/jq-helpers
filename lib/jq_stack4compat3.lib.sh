
for f in init deinit precall call option function envfunction ifndef cat gen run modload modcall modprecall; do

code='jq_cmd4_'"${f}"'() {
	echo >&2 "WARNING: COMPAT: fixed from \"'"$f"'\" to \":'"$f"'\""
	jq_stack4 ":'"$f"'" "$@"
}'
	eval "$code"
done

jq_cmd4_locals() { jq_stack4 "$@"; }
jq_cmd4_rawdef() {
	echo >&2 "WARNING: OBSOLETE \"rawdef\" fixed by using \":function\""
	shift; jq_stack4 ":function" "$@"
}

jq_stack3() { JQ_STACK4_MODDIR="$JQ_STACK3_MODDIR" jq_stack4 :with external :else external "$@"; }
