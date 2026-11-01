# Day 16 labs: strings, part 1 (literals and arrays, walking with a pointer, strcpy, strcat, strcmp)
DAY_TITLE="Strings, part 1: walking a string, strcpy, strcat and strcmp"

ctask 1 dashes.c "Needs exactly one argument. Walk the argument with a char pointer (for (char *p = argv[1]; *p != '\\0'; p++)) and print its characters with a dash between neighbours, then a newline. Example: ./dashes abc prints a-b-c. An empty argument prints just a newline. With any other number of arguments: usage message to standard error, nothing on standard output, exit status 1. Otherwise exit status 0."
crun 'abc'
crun 'x'
crun '""'
crun '"hi there"'
crun ''
crun 'a b'

ctask 2 tail.c "Usage: ./tail WORD N (N read with atoi). Make a char array of exactly the right size (strlen(WORD) - N + 1), copy the end of WORD starting at index N into it with strcpy (hint: argv[1] + N), and print it followed by ' (length L)' and a newline, where L is strlen of the copy (%zu). Example: ./tail CISC220 4 prints 220 (length 3). If N is negative or bigger than strlen(WORD), or there are not exactly two arguments: message to standard error, exit status 1. Otherwise exit status 0."
crun 'CISC220 4'
crun 'hello 0'
crun 'hello 5'
crun 'hello 6'
crun 'abc -1'
crun 'abc'

ctask 3 joinall.c "Join all the arguments with a + between them into ONE char array of capacity 31 (so the joined string can be at most 30 characters), using strcpy/strcat (start with an empty string: buf[0] = '\\0'). Before each strcat, check that the result will still fit (current length + new length + 1 for the '\\0', plus 1 more for the '+'); if it would not, print 'joinall: too long' to standard error and exit with status 1 without printing anything on standard output. Otherwise print the joined string and a newline, exit status 0. Example: ./joinall a bc d prints a+bc+d. With no arguments: usage message to standard error, exit status 1."
crun 'a bc d'
crun 'solo'
crun 'abcdefghij klmnopqrs tuvwxyz12'
crun 'abcdefghij klmnopqrs tuvwxyz123'
crun '"" x'
crun ''

ctask 4 first.c "Print the argument that comes first in dictionary order (case sensitive: compare with strcmp, so uppercase letters come before lowercase), and its argument number, as: first: apple (argument 3) and a newline. If two equal arguments are both first, report the earlier one. Exit status 0. With no arguments: usage message to standard error, exit status 1."
crun 'pear plum apple fig'
crun 'zoo Zoo zoo'
crun 'b a a'
crun 'only'
crun ''

ctask 5 ordered.c "This is the blank writing item of Day 16 (modeled on the Fall 2016 final, Q4, with arguments instead of file lines). Check every argument's length first: if any is longer than 20 characters, print an error message to standard error and exit with status 1. Then compare neighbours with strcmp. If they are all in order (equal neighbours are fine), print 'arguments are in order' and exit with status 0. Otherwise print 'arguments out of order:' and then the first pair that is out of order, each on its own line indented by two spaces, and exit with status 1. With no arguments: usage message to standard error, exit status 1."
crun 'apple banana grape grape orange'
crun 'apple grape banana peach orange'
crun 'Zebra apple'
crun 'apple Zebra'
crun 'one'
crun 'abcdefghijklmnopqrstu a'
crun ''
