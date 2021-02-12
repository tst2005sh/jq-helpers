
Require() {
	if [ -z "$scriptdir" ]; then
		echo >&2 "ERROR: scriptdir variable not defined"
		return 1
	fi
	. "${scriptdir}/mods/$1.mod.sh"
}
