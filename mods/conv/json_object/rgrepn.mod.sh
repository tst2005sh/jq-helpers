json_object_to_rgrepn() {
	jq '
	map(
		(if (.dir|startswith("/")) then ("") else ("./") end) +
		.dir + "/" + .file + ":" + (.n|tostring) + ":" + .value
	)
	'|jq -r '.[]'
}
