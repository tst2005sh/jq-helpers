rgrep_to_rgrepn() {
	local lastpathkey='' pathkey='' path='' key='' value='' count=1
	while read -r line; do
		pathkey="${line%%:*}" # easy parse...
		value="${line#*:}"
		if [ "$lastpathkey" = "$pathkey" ]; then
			count=$((${count:-1} +1))
		else
			count=1
		fi
		printf '%s:%s:%s\n' "$pathkey" "$count" "$value"
		lastpathkey="$pathkey"
	done
}
