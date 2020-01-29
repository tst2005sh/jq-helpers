jq_stack_oneline() {
	jq_stack init
	while [ $# -gt 0 ]; do
		case "$1" in
			(-2) jq_stack option "$2" "$3"; shift 2;;
			(-3) jq_stack option "$2" "$3" "$4"; shift 3;;
			(-f|-L|--f*|--arg*|--indent|--slurp*|--run*)
				echo >&2 "ERROR: please use -2 $1 ... or -3 $1 ... ..."
				return 1
			;;
			(-*) jq_stack option "$1" ;;
			(*:)
				case "$1" in
				(*'('*)	# foo(...):
					jq_stack modcall "${1%:}"
					# jq_stack modload "$1 cut at ("
					# jq_stack call "$1 without :"
				;;
				(*)	# foo:
					jq_stack modload "${1%:}"
					jq_stack envfunction "${1%:}"
				;;
				esac
			;;
			(*)
				jq_stack call "$1"
			;;
		esac
		shift
	done
	jq_stack run
}

#jq_stack online -c 'foo:' 'foo("x")' 'bar("y")'
