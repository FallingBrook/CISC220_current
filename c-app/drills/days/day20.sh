# Day 20 labs: a string data type, part 1 (struct qstr: create, copy, get, set, destroy)
DAY_TITLE="A string data type, part 1: struct qstr"

ctask 1 qinfo.c "Put struct qstr (members length, capacity, data, in that order), qstr_alloc, qstr_new, qstr_fromcstr and qstr_destroy from today's lesson at the top of your file (default capacity 8). For each command line argument, make a qstr with qstr_fromcstr, print a line of the form \"CISC220\": length = 7, capacity = 8 (the data in double quotes, then its length and capacity), and destroy it. With no arguments, make one qstr with qstr_new, print it the same way and destroy it. Exit status 0."
crun ''
crun 'CISC220'
crun '"two words" ""'
crun 'a bb ccc dddddddd'

ctask 2 qcopy.c "Exactly one argument. Make s = qstr_fromcstr(argv[1]) and t = qstr_copy(s) (write qstr_copy as in the lesson: a deep copy with its own array). Using only qstr_get and qstr_set (no t->data[i]), change every lowercase vowel (a e i o u) in t to '*'. Print three lines: original: S, copy: T and changed: N (how many characters were changed). Destroy both. Exit status 0. With no argument or more than one: a usage message to standard error and exit status 1."
crun 'education'
crun 'rhythm'
crun '"Queens University"'
crun ''
crun 'a b'

ctask 3 qat.c "The first argument is a string, the others (at least one) are integer indexes. Make a qstr from the string. For each index argument, in order, use qstr_get to print a line ARG: c (the argument as typed, a colon, a space, the character at that index), or ARG: out of range if qstr_get returns NULL. A negative index is out of range (do not pass it to qstr_get). Destroy the qstr. Exit status 0 if every index was valid, 2 if any was out of range. With fewer than two arguments: a usage message to standard error and exit status 1."
crun 'hello 0 4'
crun 'hello 1 5 2'
crun 'x -1 0'
crun '"" 0'
crun 'hello'

ctask 4 qcut.c "Two arguments: a string and a single character. Make a qstr from the string, then use qstr_get and qstr_set to replace every occurrence of the character by the null character '\\0'. The qstr's length does not change. Print length = L (the qstr's length), then strlen = K (strlen of its data), then one line showing all L characters of the qstr, with '|' printed in place of each '\\0'. Destroy the qstr; exit status 0. With the wrong number of arguments or a second argument that is not exactly one character: a usage message to standard error and exit status 1."
crun "'a,b,,c' ,"
crun "',x,' ,"
crun 'hello z'
crun "'2026-11-20' -"
crun 'hello ab'
crun 'hello'
