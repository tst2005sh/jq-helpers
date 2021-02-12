html_to_xml() {
	if ! command -v tidy >/dev/null 2>&1; then
		echo >&2 "Command required: tidy (please install tidy, maybe: apt-get install tidy ?)"
		return 1
	fi
	tidy -q -asxml 2>&-
}
