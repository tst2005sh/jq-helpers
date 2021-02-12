
conv() {
	if [ $# -lt 2 ]; then
		echo >&2 "Usage: conv <from> <to> [args...]"
		return 1
	fi
#	if [ "$1" = raw ]; then
#		Require "encode/$2"
#	elif [ "$2" = raw ]; then
#		Require "decode/$1"
#	else
		Require "conv/$1/$2"
#	fi
	local name="$1_to_$2";shift 2
	"$name" "$@"
}

encode() {
	if [ $# -lt 1 ]; then
		echo >&2 "Usage: encode <to>"
		return 1
	fi
	conv raw "$1"
}
decode() {
	if [ $# -lt 1 ]; then
		echo >&2 "Usage: decode <from>"
		return 1
	fi
	conv "$1" raw
}
