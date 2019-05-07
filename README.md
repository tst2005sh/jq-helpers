# jq helpers

## needs and goal

I made my own shell function. I use them with shell pipe.

I got things like
```bash

unpack() {
	jq '.data'
}
pack() {
	jq '{"data":.}'
}
sort_by_id() {
	jq 'sort_by("id")'
}
cat file.json | unpack | sort_by_id | pack > file2.json
```

Without shell function it equals to
```bash
cat file.json | jq '.data' | jq 'sort_by("id")' | jq '{"data":.}' > file2.json
```

it should be reduced to one jq call :
```bash
jq '.data | sort_by("id") | {"data":.}' < file.json > file2.json
```

But I lost all the modular work done with shell functions.

Then I made `jq_stack`

The previous line could be made with jq_stack like :
```bash
jq_stack init
jq_stack call '.data'
jq_stack call 'sort_by("id")'
jq_stack call '{"data":.}'
jq_stack run < file.json > file2.json
```

But the real use is like :

```bash

unpack() {
	jq_stack call '.data'
}
pack() {
	jq_stack call '{"data":.}'
}
sort_by() {
	jq_stack call 'sort_by("id")'
}

jq_stack init
unpack
sort_by_id
pack
cat file.json | jq_stack run > file2.json
```



## jq_stack

A shell function that help to prepare a jq call.
It supports :
* jq options
* jq function definition
* jq filter

## jq_run

A shell function made to 

## limitation

* jq_run: It only supports function name, not argument

# Real use-case

## jsondiff

My current first use case is [jsondiff]().

I use in shell :
```bash

# load all the "lib"
. ./lib/jq_stack.lib.sh
. ./lib/jq_run.lib.sh
. ./lib/jq.hide_last_array_index.lib.sh
. ./lib/jq.json2flat.lib.sh
. ./lib/jq.json2ndjson.lib.sh
. ./lib/jq.sortallarrays.lib.sh

# and call
jq_run json2flat hide_last_array_index sortallarrays json2ndjson
```

That produce only one jq (big) call :
```bash
jq -S -c '
        def json2flat:
                .|reduce ( tostream|select(length==2) ) as $i ( {}; .[ $i[0]|map(
                        if type=="number" then
                                "[" + tostring + "]"
                        elif (tostring|test("^[a-zA-Z0-9_]*$")) then
                                "." + tostring
                        else
                                "[" + tojson + "]"
                        end
                ) | join("")] = $i[1] )
        ;

        def hide_last_array_index:
                to_entries
                | map(.key|= gsub("\\[([0-9]+)\\]$";"[]"))
                | map( [.key, .value] )
                | map_values( {"key": .[0], "value": .[1] } )
                | map([.]|from_entries)
        ;

        # Apply f to composite entities recursively, and to atoms
        def walk(f):
                . as $in
                | if type == "object" then
                        reduce keys[] as $key
                                ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
                elif type == "array" then map( walk(f) ) | f
                else f
                end
        ;
        def sortallarrays:
                walk(if type == "array" and length > 1 then sort else . end)
        ;
.|json2flat|hide_last_array_index|sortallarrays|.[]'
```
