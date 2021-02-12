# html -> xml -> json
pata builtin Load "$DIR/xml"
pata builtin Load "$DIR/../xml/$NAME"
html_to_json() {
	html_to_xml | xml_to_json;
}
