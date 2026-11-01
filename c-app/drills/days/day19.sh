# Day 19 labs: dynamic memory, part 2: pointers to pointers, realloc, structs on the heap
DAY_TITLE="Dynamic memory, part 2: int **, realloc and structs on the heap"

ctask 1 evens.c "The arguments are integers (zero or more). Keep the even ones (v % 2 == 0, so 0 and negative even numbers count) in a heap array that starts with capacity 1: int *a = malloc(1 * sizeof(int)). Before storing a value in a full array, double its capacity with realloc (assign the result to a temporary pointer and check it for NULL first) and print a line: capacity 2 (the new capacity). At the end print the even values on one line separated by single spaces (just an empty line if there are none), then a line: count = C. free the array; exit status 0."
crun '1 2 3 4 5 6 8'
crun ''
crun '7 9 11'
crun '0 -2 -4 6 10 12 14 16 18'
crun '4'

ctask 2 mkrange.c "The program gets three integers: lo hi step (atoi). Write the function size_t make_range(int lo, int hi, int step, int **out) that mallocs an array of EXACTLY as many ints as needed for lo, lo + step, lo + 2*step, ... (every value <= hi), fills it, stores the array's address in *out, and returns the number of values. If step <= 0 or lo > hi, it allocates nothing, sets *out to NULL and returns 0. main declares int *r; calls make_range(..., &r); and prints the values on one line separated by single spaces, then a line: n = N. If the count is 0 it prints just: empty. free the array; exit status 0. If there are not exactly three arguments: usage message to standard error, exit status 1."
crun '1 10 3'
crun '5 5 1'
crun '-6 6 4'
crun '0 20 5'
crun '9 2 1'
crun '1 10 0'
crun '1 2'

ctask 3 repeat.c "The program gets a word and a number n (1 to 50). Build a heap string that holds the word repeated n times: start with char *str = malloc(1) holding the empty string, and n times grow it with realloc to exactly strlen(str) + strlen(word) + 1 bytes (through a temporary pointer checked for NULL), then strcat the word onto it and print a line k: STR (k is 1, 2, ..., n). Finally print: length = L (strlen of the result, %zu). free the string; exit status 0. If there are not exactly two arguments, or n is outside 1 to 50: message to standard error, exit status 1."
crun 'ab 3'
crun 'heap 1'
crun '"x y" 4'
crun 'C 10'
crun 'ab 0'
crun 'ab'

ctask 4 points.c "The arguments come in pairs x y (atof); there is at least one pair. Define struct point2 with double members x and y. malloc an array of exactly n struct point2 (n = the number of pairs) and fill it. Write struct point2 *farthest(struct point2 *pts, size_t n) that returns a pointer to the point farthest from the origin (largest x*x + y*y; the first one if there is a tie). main prints every point as (1.00, -2.50) (each number with %.2f), one per line, then farthest: (x, y) in the same format. Then, through the returned pointer and ->, it moves that point to (0, 0), prints a line after: and all the points again. free the array; exit status 0. With no arguments or an odd number of arguments: usage message to standard error, exit status 1."
crun '1 2 -3 4 0.5 0.5'
crun '2 2'
crun '3 4 -4 3 1 1'
crun '0 0 0 -1.5'
crun '1 2 3'
crun ''

ctask 5 upper.c "The arguments are words (at least one). Make heap copies of them: malloc an array of argc - 1 char pointers (char **copies), then for each word malloc exactly strlen(word) + 1 bytes and strcpy the word into it. Change every lowercase letter a to z in the COPIES to uppercase (c - 'a' + 'A'). Print each copy on its own line, then a line: originals: followed by each original word after a single space (they must be unchanged). free every copy and then the array of pointers; exit status 0. With no arguments: usage message to standard error, exit status 1."
crun 'hello world'
crun 'Heap'
crun 'a1b2 "two words" XyZ'
crun ''
