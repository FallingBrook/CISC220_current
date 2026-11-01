# Day 21 labs: a string data type, part 2 (qstr_remrange, qstr_ensure_capacity, qstr_assign, qstr_concat)
DAY_TITLE="A string data type, part 2: removing, growing, assigning, joining"

ctask 1 qrem.c "Put struct qstr, qstr_alloc, qstr_new, qstr_fromcstr and qstr_destroy (Day 20) and qstr_remrange (today) at the top of your file. Three arguments: a string, start and stop (atoi). Make a qstr from the string and call qstr_remrange(s, start, stop). If start or stop is negative (do not pass it to qstr_remrange) or qstr_remrange returns NULL: print a message to standard error, destroy the qstr and exit with status 2. Otherwise print the result in square brackets, e.g. [ABCDH], then a line length = L, capacity = C, destroy the qstr and exit 0. With the wrong number of arguments: usage message to standard error, exit status 1."
crun 'ABCDEFGH 4 7'
crun 'hello 0 5'
crun 'hello 2 2'
crun 'hello 4 5'
crun 'hello 3 9'
crun 'hello 3 1'
crun 'hello -1 2'
crun 'hello 1'

ctask 2 qtrim.c "For each command line argument (zero or more), make a qstr, remove the spaces at its start and at its end with qstr_remrange (one call for the leading spaces, one for the trailing ones; spaces in the middle stay), and print a line [TEXT] length L, then destroy it. Exit status 0."
crun "'  hello  '"
crun "'no spaces' ' a b ' '     ' ''"
crun ''
crun "'   left' 'right   '"

ctask 3 qdedup.c "Exactly one argument. Make a qstr from it and use qstr_remrange to remove every character that is equal to the character just before it, so each run of equal characters becomes one (aaabccdddd becomes abcd). Print the result on one line, then removed = N (how many characters were removed). Destroy the qstr; exit status 0. With no argument or more than one: usage message to standard error, exit status 1."
crun 'aaabccdddd'
crun 'abc'
crun "'bookkeeper'"
crun "'    '"
crun "''"
crun 'a b'

ctask 4 qdouble.c "Write qstr_ensure_capacity and qstr_concat as in today's lesson (the capacity grows to exactly what is needed). Two arguments: a word and n (1 to 6). Make s = qstr_fromcstr(word) and print 0: DATA (length L, capacity C). Then n times call qstr_concat(s, s) (s onto itself) and print the same kind of line, numbered 1 to n. Destroy s; exit status 0. With the wrong number of arguments or n outside 1 to 6: message to standard error, exit status 1."
crun 'ab 3'
crun 'x 6'
crun 'CISC220 1'
crun "'' 2"
crun 'ab 0'
crun 'ab 7'
crun 'ab'

ctask 5 qlongest.c "Write qstr_ensure_capacity and qstr_assign as in today's lesson. One or more arguments (words). best = qstr_new(). For each argument make a qstr w; if it is the first argument, or longer than best (a tie does not count), copy it into best with qstr_assign and print new longest: WORD (length L, capacity C) using best's members. Destroy w each time. At the end print longest: WORD, destroy best, exit status 0. With no arguments: usage message to standard error, exit status 1."
crun 'a bb ccc'
crun 'elephant cat hippopotamus dog rhinoceros'
crun 'tie tie also'
crun "''"
crun 'one-very-long-word short'
crun ''
