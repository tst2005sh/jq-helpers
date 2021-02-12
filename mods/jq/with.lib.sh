jq_with() {
	local key="$1";shift
	local cmd="$1";shift
	local value="$1";shift
	case "$cmd" in
		('grep') echo '.'"$key"'|test("'"$value"'")' ;;
		('!grep') echo '.'"$key"'|test("'"$value"'")|not' ;;
		('='|'==')    echo '.'"$key"'=="'"$value"'"' ;;
		('!=')   echo '.'"$key"'!="'"$value"'"' ;;
		(*) echo >&2 ERROR:WTF ;;
	esac
}
jq_without() {
	local key="$1";shift
	local cmd="!$1";shift
	cmd="${cmd#!!}"
	jq_with "$key" "$cmd" "$@"
}
jq_opwiths() {
	if [ $# -le 4 ]; then
		shift; jq_with "$@";
		return $?
	fi
	local finalcmd="$1";shift
        local key="$1";shift
        local cmd="$1";shift

	local i=1
	for v in "$@"; do
		if [ $i -eq 1 ]; then shift $#; fi
		i=$(( $i + 1 ))
		set -- "$@" "$(jq_with "$key" "$cmd" "$v")"
	done
	"$finalcmd" "$@"
}

jq_orwith() {
	jq_opwiths jq_or "$@"
}
# With() { jq_orwith "$@"; }

jq_andwith() {
	jq_opwiths jq_and "$@"
}
