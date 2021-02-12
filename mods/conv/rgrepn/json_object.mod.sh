
# - remove the './' prefix
# - split('/') limit 1 : dir / rest (subpath/file:value)
# - split(':') limit 1 : subpath/file : value
# - pathtofile = dir + subpath/file
# - pathdir = pathtofile:split( last / )

#jq_function_split1='def split1($sep): [.|split($sep)|(first,(skipfirst|join($sep)))];'
#jq_function_splitn='def splitn($sep;$n): [.|split($sep)|(.[0:$n],(.[$n:]|join($sep)))];'

# RGREP
# id '/' key ':' value
# ([^/]+) '/' ([^:]+) ':' (.*)

# RGREPN
# id '/' key ':' linenum ':' value
# ([^/]+) '/' ([^:]+) ':' ([^:]+) ':' (.*)

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

jq_function_trytonumber='
	def trytonumber:
		if (try (.|tonumber) catch false) then (.|tonumber) else (.) end
	;'

#jq_function_maybe='def maybe(f): if (try (f) catch false) then (f) else (.) end;'
jq_function_maybe='
	def maybe(f):
		(f?//.)
	;'

jq_function_ifempty='
	def ifempty($v):
		if (.=="") then ($v) else (.) end
	;'

rgrepn_to_json_object() {
	jq -Rn '
	'"$jq_function_removeprefix"'
	'"$jq_function_skipfirst"'
	'"$jq_function_split_skipfirst"'
	'"$jq_function_trytonumber"'
	'"$jq_function_ifempty"'
	'"$jq_function_maybe"'
	[inputs] |
	map(
		removeprefix |
		{
			"dir":   (split("/")|first),
			"file":  (split_skipfirst("/")|split(":")|first),
			"n":     (split_skipfirst("/")|split_skipfirst(":")|split(":")|first|ifempty("1")|maybe(tonumber)),
			"value": (split_skipfirst("/")|split_skipfirst(":")|split_skipfirst(":")),
		}
	)'
}
