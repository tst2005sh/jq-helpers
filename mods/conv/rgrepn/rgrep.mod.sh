rgrepn_to_rgrep() {
	cut -d: -f1,3-
#	while read -r line; do
#		pathkey="${line%%:*}" # easy parse...
#		count_value="${line#*:}"
#		printf '%s:%s\n' "$pathkey" "$value"
#		lastpathkey="$pathkey"
#	done
}
