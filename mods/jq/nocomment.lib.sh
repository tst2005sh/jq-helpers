# drop text between parenthesis
# <- foo(commenthere)bar
# -> foobar
jq_function_nocomment='def nocomment(): gsub("\\([^\\(\\)]*\\)";"");'
