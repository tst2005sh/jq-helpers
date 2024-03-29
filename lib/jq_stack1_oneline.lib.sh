jq_stack1_oneline() {
	jq_stack1 init
	local dryrun=''
	while [ $# -gt 0 ]; do
		case "$1" in
			(-n) dryrun='-n';;
			(-1) jq_stack1 option "$2";shift;;
			(-2) for opt in "$2" "$3"     ; do jq_stack1 option "$opt"; done; shift 2;;
			(-3) for opt in "$2" "$3" "$4"; do jq_stack1 option "$opt"; done; shift 3;;
			(-[sRncCMaSrje]|--version|--seq|--stream|--slurp|--raw-input|--null-input|--compact-output|--tab|--color-output|--monochrome-output|--ascii-output|--unbuffered|--sort-keys|--raw-output|--join-output|--exit-status)
				jq_stack1 option "$1"
			;;
			(--indent|-f|--from-file|-L) # 1 arg
				for opt in "$1" "$2"; do jq_stack1 option "$opt"; done; shift
			;;
			(--arg|--argjson|--slurpfile|--argfile) # 2 args
				for opt in "$1" "$2" "$3"; do jq_stack1 option "$opt"; done; shift 2
			;;
			(-*)
				echo >&2 "ERROR: please use -1 $1 or -2 $1 arg2 or -3 $1 arg2 arg3"
				return 1
			;;
			(*:)
				case "$1" in
				(*'('*)	# foo(...):
					jq_stack1 modcall "${1%:}"
					# jq_stack1 modload "$1 cut at ("
					# jq_stack1 call "$1 without :"
				;;
				(*)	# foo:
					jq_stack1 modload "${1%:}"
					jq_stack1 envfunction "${1%:}"
				;;
				esac
			;;
			(*)
				jq_stack1 call "$1"
			;;
		esac
		shift
	done
	jq_stack1 run $dryrun
}

#jq_stack1 oneline -c 'foo:' 'foo("x")' 'bar("y")'
