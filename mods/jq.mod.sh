
#echo NAMESPACE=$NAMESPACE DIR=$DIR NAME=$NAME

for f in "$PATA_MODSDIR/$NAMESPACE/$DIR/$NAME"/*.lib.sh; do
	[ -e "$f" ] || continue
	#echo >&2 "- load $f"
	pata builtin Source "$f"
#	case "$f" in
#		(/*) ;;
#		(*) f="./$f" ;;
#	esac
#	. "$f"
done

jqf() {
	local vname="$(printf '${%s%s}' "jq_function_" "${1%%(*}")"
	#echo >&2 "jqf: vname=$vname ; $1"
	jq="$(eval echo "$vname") ${2:-$1}";
	#echo >&2 "jqf: jq=$jq"
	jq ${JQ_OPTIONS:-} "$jq";
}

# TODO move into shell/text/args util ?
ArgsJoin() {
	local b="$1";shift
	local e="$1";shift
	local sep="$1";shift

	[ $# -eq 0 ] || printf '%s' "$b"
	while [ $# -gt 0 ]; do
		if [ $# -eq 1 ]; then
			printf '%s' "$1" "$e"
		else
			printf '%s%s' "$1" "$sep"
		fi
		shift
	done
}
jq_and() { ArgsJoin '(' ')' ') and (' "$@"; }
jq_or() { ArgsJoin '(' ')' ') or (' "$@"; }
