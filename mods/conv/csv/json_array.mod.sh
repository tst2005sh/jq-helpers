# csv -> json_array
csv_to_json_array() {
	"${PATA_DIR:-.}/thirdparty/csv2json/csv2json_array.py" "$@";
}
