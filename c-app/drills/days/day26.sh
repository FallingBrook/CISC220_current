# Day 26 labs: input and output, part 1: streams, fopen/fclose, fgetc, fgets, fscanf, fprintf/fputs
DAY_TITLE="Input and output, part 1: streams, files, characters, lines and fscanf"

ctask 1 charstats.c "Read standard input one character at a time with fgetc(stdin) (or getchar()) until EOF. Store each character in an int, not a char. Then print three lines: characters: N (every character read, newlines included), lines: L (the number of newline characters) and digits: D (the number of characters '0' to '9'). Exit status 0. Try it by hand with: printf 'ab1\\n22\\n' | ./charstats"
crun '' 'hello\nworld\n'
crun '' ''
crun '' 'no newline 123'
crun '' 'a1b2\n\n33\n'
crun '' '   \n\t\n'

ctask 2 numbered.c "Read standard input one line at a time with fgets into a char buffer of 100 (every line has fewer than 99 characters). Remove the newline at the end of the line if there is one (the last line may not have one). Print each line as its number in a field of width 3, then '| ', then the line, then a newline: printf(\"%3d| %s\\n\", n, buf). After the last line print N lines (for example 2 lines). Exit status 0."
crun '' 'first\nsecond\n'
crun '' ''
crun '' 'one line without newline'
crun '' 'a\n\nc\nd d d\ne\nf\ng\nh\ni\nj\nk\n'

ctask 3 total.c "Read integers from standard input with fscanf(stdin, \"%d\", &x) for as long as fscanf returns 1. Print count = C and sum = S on two lines (use a long for the sum and %ld). Then look at the LAST value fscanf returned: if it was EOF the input ended normally, so exit with status 0; otherwise (it returned 0 because the input had something that is not an integer) print an error message to standard error and exit with status 1. Integers may be separated by any spaces and newlines."
crun '' '1 2 3\n'
crun '' ''
crun '' '5\n-2\n   10'
crun '' '4 5 x 6\n'
crun '' 'abc'
crun '' '2147483647 2147483647\n'

ctask 4 savelines.c "The program needs exactly one argument, a file name; otherwise print a usage message to standard error and exit with status 1. Open the file for writing (\"w\"); if fopen returns NULL, call perror and exit with status 1. Read standard input line by line with fgets (every line ends with a newline and is shorter than 99 characters) and write each line to the file preceded by its line number, a colon and a space (fprintf for the number, fputs for the line), e.g. 1: hello. Close the file, open it AGAIN for reading, copy its contents to standard output one character at a time (fgetc and putchar), close it, and finally print saved N lines in FILENAME. Exit status 0."
crun 'out.txt' 'hello\nworld\n'
crun 'empty.txt' ''
crun 'one.txt' 'just one line\n'
crun 'no_such_dir/out.txt' 'x\n'
crun '' 'x\n'
crun 'a.txt b.txt' ''

ctask 5 wordfile.c "Arguments: a file name, then one or more words (each shorter than 100 characters). With fewer than 2 arguments, print a usage message to standard error and exit with status 1. Write the words to the file, one per line, each followed by a space and its length: fprintf(f, \"%s %zu\\n\", word, strlen(word)). If fopen fails, perror and exit with status 1. Close the file, reopen it for reading and read it back with fscanf(f, \"%99s %zu\", word, &len) while it returns 2. Print total length: T (the sum of the lengths) and longest: W (L) for the longest word and its length; if several words tie, report the FIRST. Exit status 0. Do not compute the answer from argv: the point is to read the file back."
crun 'w.txt cat elephant dog'
crun 'w.txt a'
crun 'w.txt abc xyz ab'
crun 'w.txt'
crun ''
crun 'missing/w.txt hello'
