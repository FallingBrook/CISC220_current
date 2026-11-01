# Day 3 labs: arrays, strings and command line arguments (none of these is concat2.c)
DAY_TITLE="Arrays, strings and command line arguments"

ctask 1 arglens.c "Print every command line argument (not the program name) with its length, one per line, in the form:  1: \"hello\" has length 5   (the argument number, a colon, a space, the argument in double quotes, then 'has length' and the length from strlen, printed with %zu). If there are no arguments, print exactly: no arguments. Always exit with status 0."
crun ''
crun 'hello'
crun 'a "two words" ""'
crun '"  spaced  " x yz'

ctask 2 reverse.c "Needs exactly one argument. Build a NEW string (a char array of the right size, ending with '\\0') that holds argv[1] backwards, then print it followed by a newline. Example: ./reverse abc prints cba. With any other number of arguments, print a usage message to standard error (fprintf(stderr, ...)), print nothing on standard output, and exit with status 1. Otherwise exit with status 0."
crun 'abc'
crun 'racecar'
crun '""'
crun '"hello world"'
crun ''
crun 'a b'

ctask 3 count.c "Usage: ./count TEXT C. Print how many times the character C appears in TEXT, as a number followed by a newline. Example: ./count banana a prints 3. If the number of arguments is not exactly 2, or the second argument is not exactly one character long, print an error message to standard error and exit with status 1 (nothing on standard output). Otherwise exit with status 0."
crun 'banana a'
crun 'mississippi s'
crun 'hello z'
crun '"" x'
crun '"a b c" " "'
crun 'hello ll'
crun 'hello ""'
crun ''
crun 'onlyone'

ctask 4 initials.c "Build a NEW string made of the first character of each argument, in order, and print it with puts. Skip empty arguments (\"\"), since they have no first character. Example: ./initials portable network graphics prints png. With no arguments (or only empty ones) the string is empty, so puts prints just a newline. Always exit with status 0. Hint: argc chars are enough for the array (why?)."
crun 'portable network graphics'
crun ''
crun 'a'
crun '"" hello ""'
crun '"new york" city'
