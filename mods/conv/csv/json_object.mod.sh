# csv -> json_object
csv_to_json_object() {
	"${PATA_DIR:-.}/thirdparty/csv2json/csv2json_object.py" "$@";
}
