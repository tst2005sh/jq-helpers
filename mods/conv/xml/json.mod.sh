xml_to_json() {
	if [ ! -x "${PATA_DIR:-.}/thirdparty/xml2json/xml2json.py" ]; then
		echo >&2 "Missing util. No such ${PATA_DIR:-.}/xml2json/xml2json.py (Maybe git clone https://github.com/hay/xml2json ?)"
		return 1
	fi
	"${PATA_DIR:-.}/thirdparty/xml2json/xml2json.py" --strip_namespace
}
