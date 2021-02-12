
json_object_to_json_array() {
	Require jq;
	if [ $# -eq 0 ]; then
		jqf 'object_to_array'
	else
		keys="$1";shift
		case "$keys" in
			('['*']') ;;
			('['*) keys="$keys"']' ;;
			(*']') keys='['"$keys" ;;
			(*)    keys='['"$keys"']' ;;
		esac
		jqf 'object_to_array('"$keys"')'
	fi
}
