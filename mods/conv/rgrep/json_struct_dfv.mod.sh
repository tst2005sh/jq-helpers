# rgrep -> ( json_object == json_flat_dfnv ) -> json_struct_dfv
pata builtin Load "$DIR/json_object"
pata builtin Load "$DIR/../json_flat_dfnv/$NAME"
rgrep_to_json_struct_dfv() {
	rgrep_to_json_object | json_flat_dfnv_to_json_struct_dfv;
}
