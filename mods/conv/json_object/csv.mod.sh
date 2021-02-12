# json_object -> json_array -> csv
pata builtin Load "$DIR/json_array"
pata builtin Load "$DIR/../json_array/$NAME"
json_object_to_csv() {
        json_object_to_json_array "$@" | json_array_to_csv;
}
