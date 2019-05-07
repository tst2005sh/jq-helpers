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


## limitation

* jq_run: It only supports function name, not argument
