

jq_function_unflat='
	def unflat(key):
		reduce .[] as $e ({}; .[$e | key] += [$e | del(key)])
	;'

json_flat_dfnv_to_json_struct_dfv() {
	jq '
	'"$jq_function_unflat"'
		unflat(.dir) | map_values(unflat(.file) | map_values(sort_by(.n)|map(.value)|join("\n")))
	'
}

#jq_function_unflat2='
#	def unflat2():
#		reduce .[] as {$dir, $file, $value} ({}; .[$dir][$file] += [$value])
#	;'
#json_flat_dfnv_to_json_struct_dfv() {
#	jq '
#	'"$jq_function_unflat2"'
#		unflat2() | map_values(sort_by(.n)|map(.value)|join("\n")))
#		        # | map_values(            map_values( join("\n")))
#	'
#}

#printf '%s\n' '[{"dir": "D", "file": "F", "n":2, "value":"V2"},{"dir": "D", "file": "F", "n":1, "value":"V1"}]' | json_dfnv_flat_to_json_dfnv_unflat
#printf '%s\n' '[{"dir": "D", "file": "F", "n":"z", "value":"V2"},{"dir": "D", "file": "F", "n":1, "value":"V1"}]' | json_dfnv_flat_to_json_dfnv_unflat

# [{"dir": "D", "file": "F", "n":1, "value":"V"},{"dir": "D", "file": "F", "n":1, "value":"V2"}]
# => {"D":{"F":"V1\nV2"}}
