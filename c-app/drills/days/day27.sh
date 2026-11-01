# Day 27 labs: input and output, part 2: file position, ftell, fseek, rewind, update modes, fflush, structs from input
DAY_TITLE="Input and output, part 2: file position, fseek, update modes, and reading records"

ctask 1 charat.c "Arguments: a file name and a text. With any other number of arguments, print a usage message to standard error and exit with status 1. Open the file with mode \"w+\" (if fopen returns NULL, perror and exit with status 1) and write the text into it with fputs (add no newline). Then use fseek to the end and ftell to find the file size and print size: N. Next read positions (long integers) from standard input with fscanf(stdin, \"%ld\", &pos) while it returns 1. For each position: if 0 <= pos < size, fseek to it with SEEK_SET, read one character with fgetc and print pos: c (for example 4: o); otherwise print pos: out of range. Close the file. Exit status 0. Every character must come from the file, not from argv."
crun 'p.txt hello' '0\n4\n5\n-1\n2\n'
crun 'p.txt "a b c"' '1 3 4\n'
crun 'p.txt ""' '0\n'
crun 'p.txt abcdefghijklmnopqrstuvwxyz' '25 0 13\n100\n'
crun 'p.txt' '0\n'
crun 'nodir/p.txt hi' '0\n'

ctask 2 tail.c "Arguments: a file name and a number N. If there are not exactly 2 arguments, or atoi(N) is not greater than 0, print a usage message to standard error and exit with status 1. Copy all of standard input into the file (mode \"w\"; on failure perror and exit 1), close it, and open it again for reading. Find the size S with fseek(f, 0, SEEK_END) and ftell. Let K be N, or S if the file has fewer than N characters. Print the line last K of S characters: and then the last K characters of the file exactly as they are (use fseek to jump to position S - K, then fgetc/putchar to the end). Exit status 0."
crun 'out.txt 4' 'hello world\n'
crun 'out.txt 100' 'abc\n'
crun 'out.txt 3' ''
crun 'out.txt 12' 'line one\nline two\nline three\n'
crun 'out.txt 0' 'abc\n'
crun 'out.txt' 'abc\n'
crun 'nodir/out.txt 2' 'abc\n'

ctask 3 replace.c "Arguments: a file name, a target character and a replacement character (each of the last two must be exactly one character long). Otherwise print a usage message to standard error and exit with status 1. Copy all of standard input into the file (mode \"w\"; on failure perror and exit 1) and close it. Reopen it with mode \"r+\" and replace every target character by the replacement IN PLACE, the replace_char.c way: after reading a target with fgetc, fseek(f, -1, SEEK_CUR), fputc the replacement, then fflush(f). Count the replacements. Then rewind the file, print its whole contents to standard output, then print replaced N. Exit status 0."
crun 'f.txt a o' 'banana\nbandana\n'
crun 'f.txt x y' 'no match here\n'
crun 'f.txt " " _' 'a b  c\nd e\n'
crun 'f.txt a b' ''
crun 'f.txt ab c' 'abc\n'
crun 'f.txt a' 'abc\n'
crun 'nodir/f.txt a b' 'abc\n'

ctask 4 players.c "Use this struct: typedef struct { char name[20]; int goals; int assists; } player; and an array player p[10]. Read standard input line by line with fgets (lines are shorter than 99 characters) and get the three fields of each line with sscanf(line, \"%19s %d %d\", ...). If a line does not give 3 values, print line L: bad input to standard error (L counts from 1) and exit with status 1. Store at most 10 players, but count every line. Then, for each stored player in input order, print name points (points = goals + assists). Then print best: NAME (P points) for the stored player with the most points (the first one if several tie), or no players if none were stored. Finally print N players, M stored. Exit status 0."
crun '' 'ana 3 4\nben 5 1\ncho 2 5\n'
crun '' ''
crun '' 'solo 0 0\n'
crun '' 'a 1 0\nb 2 0\nc 3 0\nd 4 0\ne 5 0\nf 6 0\ng 7 0\nh 8 0\ni 9 0\nj 1 1\nk 99 99\nl 0 0\n'
crun '' 'ana 3 4\nben five 1\n'
crun '' 'ana 3\n'
