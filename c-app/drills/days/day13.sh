# Day 13 labs: structs
DAY_TITLE="Structs: members, pointers to structs, arrays of structs"

ctask 1 mid.c "The program gets four numbers x1 y1 x2 y2 (convert with atof). Define struct point2 with double members x and y. Store the two points in two struct point2 variables (initialise them with { ... }). Write struct point2 midpoint(struct point2 a, struct point2 b) that returns the point halfway between a and b. main prints exactly: midpoint = (2.00, 3.50) (the real numbers, each with %.2f) and a newline; exit status 0. If there are not exactly four arguments, print a usage message to standard error and exit with status 1."
crun '1 2 3 5'
crun '0 0 0 0'
crun '-4 2.5 1 -0.5'
crun '10 20 30'
crun ''

ctask 2 rect.c "The program gets three integers: width height factor (convert with atoi). Define struct rect with int members width and height. Write void scale(struct rect *r, int factor) that multiplies both sides of the rectangle r points at by factor (use ->), and int area(const struct rect *r) that returns width times height. main makes the rectangle, prints: before: 3 x 4, area 12  then calls scale(&r, factor) and prints: after: 6 x 8, area 48  (real numbers, one line each, single spaces); exit status 0. If there are not exactly three arguments: usage message to standard error, exit status 1."
crun '3 4 2'
crun '5 1 0'
crun '7 7 1'
crun '2 9 -3'
crun '3 4'

ctask 3 books.c "Arguments come in groups of three: title author year (for example Dune Herbert 1965 Emma Austen 1815). Define struct book with members char *title, char *author (each points at its command line argument) and int year (atoi). Store the books in an array of struct book (at most 10 books). Write void print_book(const struct book *b) that prints one line: Dune by Herbert (1965). main prints every book with print_book, in order, then prints oldest:  followed by the oldest book printed with print_book on the same line (example: oldest: Emma by Austen (1815)); if several share the oldest year, use the first of them. Exit status 0. If there are no arguments, the number of arguments is not a multiple of 3, or there are more than 10 books: usage message to standard error, exit status 1."
crun 'Dune Herbert 1965 Emma Austen 1815 Neuromancer Gibson 1984'
crun '"The Hobbit" Tolkien 1937'
crun 'A X 2000 B Y 1999 C Z 1999'
crun 'Dune Herbert'
crun ''

ctask 4 words.c "Each argument is a non-empty word (1 to 20 words). Define struct wordinfo with members char first and size_t len. Write void fill(struct wordinfo info[], char *words[], size_t n) that sets info[i].first to the first character of words[i] and info[i].len to its length (strlen), for i from 0 to n - 1. main declares an array of struct wordinfo, calls fill once (hint: argv + 1 is an array of the words), then prints one line per word: the first character, a space, the length (%zu), e.g. s 6. Finally it prints: longest: pointer (7) (the first longest word if there is a tie). Exit status 0. With no words, or more than 20: usage message to standard error, exit status 1."
crun 'struct pointer arrow'
crun 'a'
crun 'cat dog emu'
crun 'x yy zz'
crun ''
