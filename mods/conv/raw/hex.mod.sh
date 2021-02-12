
#pata builtin Deps od tr || exit 1

raw_to_hex() {
	od -t x1 -An | tr -d -c '0-9a-fA-F'
}
