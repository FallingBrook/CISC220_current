# Day 17 labs: strings, part 2 (strchr, strrchr, strstr, memmove, sprintf, sscanf)
DAY_TITLE="Strings, part 2: searching, memmove, sprintf and sscanf"

ctask 1 where.c "Usage: ./where TEXT C, where C is exactly one character. Use strchr and strrchr to find the first and last C in TEXT, and print their indexes (pointer subtraction, %td) as two lines: first: 1 and last: 5 (for ./where banana a). If C does not occur, print one line: z does not occur in banana (exit status 0). If there are not exactly two arguments, or C is not exactly one character: usage message to standard error, exit status 1. Otherwise exit status 0."
crun 'banana a'
crun 'banana b'
crun 'banana z'
crun '"a b c" " "'
crun '"" a'
crun 'banana an'
crun 'banana'

ctask 2 censor.c "Usage: ./censor TEXT WORD. Copy TEXT into your own char array (TEXT may not be changed in place: make an array of strlen + 1 chars and strcpy). Use strstr to find every occurrence of WORD, from left to right, and replace each one with as many '*' as WORD has characters; after replacing one, search again starting just after it (so occurrences never overlap). Print the censored text on one line and then a line like 2 replaced. If there are not exactly two arguments, or WORD is empty: usage message to standard error, exit status 1. Otherwise exit status 0. Example: ./censor 'the cat sat' at prints the c** s** and then 2 replaced."
crun '"the cat sat" at'
crun 'aaaaa aa'
crun 'hello xyz'
crun 'hello hello'
crun '"" a'
crun 'hello ""'
crun 'hello'

ctask 3 squeeze.c "Usage: ./squeeze WORD C, where C is exactly one character. Copy WORD into your own array, then remove every C from it: find a C with strchr, and close the gap with memmove (move everything after it, including the '\\0', one place to the left; the two areas overlap, so memcpy is not allowed). Print the result and the number removed as: miiippi (4 removed) for ./squeeze mississippi s. If there are not exactly two arguments, or C is not exactly one character: usage message to standard error, exit status 1. Otherwise exit status 0."
crun 'mississippi s'
crun 'mississippi i'
crun 'aaa a'
crun 'hello z'
crun '"" x'
crun 'hello ll'
crun ''

ctask 4 date.c "Usage: ./date YYYY-MM-DD. Read the year, month and day with ONE call to sscanf, using the widths %4u-%2u-%2u, and check its return value: if it is not 3, print an error message to standard error and exit with status 1. If the month is not 1 to 12 or the day is not 1 to 31: message to standard error, exit status 1. Otherwise build the date as dd/mm/yyyy in a char array with sprintf (%02u and %04u give leading zeros), print it with puts, and exit with status 0. Example: ./date 2026-11-17 prints 17/11/2026, and ./date 2026-1-5 prints 05/01/2026. Wrong number of arguments: usage message to standard error, exit status 1."
crun '2026-11-17'
crun '2026-1-5'
crun '999-12-31'
crun '2026/11/17'
crun '2026-13-01'
crun 'tomorrow'
crun '2026-11'
crun ''

ctask 5 initials.c "This is the blank writing item of Day 17 (modeled on the Fall 2015 final, Q4). Write void initials(char *names[], char *dest) exactly as in the writing item: names ends with a NULL element; for each name write its first letter and, if it contains a space, the letter after its LAST space (strrchr); separate the initials of different names with one space; end dest with '\\0'. In main, each argument is one name: first check that no argument is empty, starts with a space or ends with a space (message to standard error, exit status 1), then call initials(argv + 1, result) (argv[argc] is always NULL) with a char array of 3 * (argc - 1) + 1 chars, and print the result and a newline. Exit status 0. With no arguments: usage message to standard error, exit status 1. Example: ./initials 'Ada Lovelace' 'Grace Brewster Hopper' Cher prints AL GH C."
crun '"Ada Lovelace" "Grace Brewster Hopper" Cher'
crun '"Alan Turing"'
crun 'x y z'
crun '"Ada Lovelace" ""'
crun '" Ada"'
crun ''
