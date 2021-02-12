# json -> rgrepn -> rgrep
pata builtin Load "$DIR/rgrepn"
pata builtin Load "$DIR/../rgrepn/$NAME"
json_to_rgrep() {
        json_to_rgrepn | rgrepn_to_rgrep;
}
