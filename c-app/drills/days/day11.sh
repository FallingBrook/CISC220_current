# Day 11 labs: pointers, part 1 (&, *, swap)
DAY_TITLE="Pointers, part 1: &, * and swap"

ctask 1 swapint.c "The program gets two integer arguments a and b (convert them with atoi). Write a function void swap(int *x, int *y) that swaps the two ints its parameters point at. main prints 'before: a = A, b = B', calls swap(&a, &b), then prints 'after: a = A, b = B' (each line ends with a newline). Example: ./swapint 3 7 prints 'before: a = 3, b = 7' then 'after: a = 7, b = 3'. Exit status 0. If there are not exactly two arguments, print a usage message to standard error and exit with status 1."
crun '3 7'
crun '-5 12'
crun '4 4'
crun '0 -1'
crun '1'
crun ''

ctask 2 clamp.c "The program gets three integer arguments x, lo and hi. Write a function void clamp(int *x, int lo, int hi) that changes the caller's variable: if *x is less than lo it becomes lo, if it is greater than hi it becomes hi, otherwise it is unchanged. main calls clamp(&x, lo, hi) and prints x and a newline. Exit status 0. If there are not exactly three arguments, or lo is greater than hi, print a message to standard error and exit with status 1."
crun '15 0 10'
crun '-4 0 10'
crun '7 0 10'
crun '0 0 10'
crun '10 0 10'
crun '5 5 5'
crun '1 9 2'
crun '1 2'

ctask 3 sort3.c "The program gets three integer arguments. Write void swap(int *x, int *y) and void sort3(int *a, int *b, int *c), which rearranges the three ints so that *a <= *b <= *c, using only comparisons and calls to swap (no arrays). Hint: compare-and-swap a,b then b,c then a,b again. main reads the arguments into int variables a, b, c, calls sort3(&a, &b, &c), and prints a b c separated by single spaces and a newline. Exit status 0. If there are not exactly three arguments, print a usage message to standard error and exit with status 1."
crun '3 1 2'
crun '9 8 7'
crun '1 2 3'
crun '5 -5 0'
crun '4 4 1'
crun '2 2 2'
crun '1 2'

ctask 4 tally.c "The program gets any number of integer arguments (possibly none). main has two variables, int total = 0 and int negs = 0. Write void tally(int x, int *total, int *negs) that adds x to the caller's total and, if x is negative, adds 1 to the caller's count of negatives. main calls tally once per argument (passing &total and &negs) and then prints two lines: 'total = T' and 'negatives = N'. Exit status 0 (no arguments is fine: both are 0)."
crun '1 2 3'
crun '5 -3 -4 10'
crun ''
crun '-1'
crun '0 0 -0'
