# Day 18 labs: dynamic memory, part 1: malloc, calloc, free
DAY_TITLE="Dynamic memory, part 1: malloc, calloc and free"

ctask 1 squares.c "The program gets one integer argument n (1 to 1000). Use malloc to allocate an array of exactly n ints (check for NULL), store the squares 1, 4, 9, ..., n*n in it, then print them on one line separated by single spaces, a newline, and then: sum = S (the sum of the squares) and a newline. free the array before returning 0. With no argument, more than one, or n outside 1 to 1000: print a usage message to standard error and exit with status 1."
crun '5'
crun '1'
crun '12'
crun '0'
crun ''
crun '3 4'

ctask 2 reverse.c "The arguments are integers (at least one). Use malloc to allocate an int array of exactly argc - 1 elements (not a fixed size like 100), copy the arguments into it with atoi, then print the elements in reverse order, one per line. free the array; exit status 0. With no arguments: print a usage message to standard error and exit with status 1. Hint: counting down with a size_t i is tricky because it can never be negative; try for (size_t i = n; i > 0; i--) and use a[i - 1]."
crun '1 2 3'
crun '42'
crun '-5 0 5 10 -10 7'
crun ''

ctask 3 histo.c "The first argument is k (1 to 20); the other arguments (zero or more) are integers. Use calloc to allocate an array of k unsigned int counters (all start at 0, so do not set them yourself). For each value v with 0 <= v < k, add one to counter v; count every other value as 'other'. Then print k lines in the form 3: 2 (the value, a colon, a space, its count) for 0 to k - 1, and a last line other: M. free the array; exit status 0. With no arguments, or k outside 1 to 20: message to standard error, exit status 1."
crun '4 0 1 1 3 3 3'
crun '3'
crun '2 5 -1 1 0 2'
crun '1 0 0 0'
crun '0 1 2'
crun ''

ctask 4 prefix.c "The arguments are integers (at least one). Read them into a malloc'd int array. Write the function double *prefix_avg(int a[], size_t n) that mallocs and RETURNS a new array of n doubles where element i is the average of a[0] to a[i] (returning NULL if malloc fails). main prints the n averages with %.2f, one per line, and frees BOTH arrays; exit status 0. With no arguments: usage message to standard error, exit status 1."
crun '2 4 9'
crun '5'
crun '1 2 3 4 5 6'
crun '-3 3 -3 3'
crun ''
