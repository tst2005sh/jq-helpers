#!/bin/sh

# RGREP
# id '/' key ':' value
# ([^/]+) '/' ([^:]+) ':' (.*)

jq_function_removeprefix='
	def removeprefix:
		if (.|startswith("./")) then (.|.[2:]) else (.) end
	;'

jq_function_skipfirst='
	def skipfirst:
		del(.[0])
	;'

jq_function_split_skipfirst='
	def split_skipfirst($sep):
		(split($sep)|skipfirst|join($sep))
	;'

rgrep_to_json_object() {
	jq -Rn '
	'"$jq_function_removeprefix"'
	'"$jq_function_skipfirst"'
	'"$jq_function_split_skipfirst"'
	[inputs] |
	map(
		removeprefix |
		{
			"dir":   (split("/")|first),
			"file":  (split_skipfirst("/")|split(":")|first),
			"value": (split_skipfirst("/")|split_skipfirst(":")),
		}
	)'
}
