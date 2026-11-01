# Day 12 labs: pointers, part 2: pointer results and pointer arithmetic
DAY_TITLE="Pointers, part 2: results through pointers and pointer arithmetic"

ctask 1 maxpos.c "Read the integer command line arguments (1 to 100 of them) into an int array with atoi. Write the notebook's function int max(int a[], size_t count, size_t *index): it returns the largest value and stores the index of that value (the first one, if it appears more than once) in the object that index points at. main declares a size_t variable, passes its address, then prints exactly: max = 9, index = 5 (with the real numbers) and a newline. Exit status 0. With no arguments (or more than 100): print a usage message to standard error and exit with status 1."
crun '6 3 1 8 7 9 4 2 5'
crun '42'
crun '-5 -2 -9'
crun '7 1 7'
crun ''

ctask 2 divide.c "The program gets two integer arguments a and b. Write void divide(int a, int b, int *quot, int *rem) that stores a / b in the object quot points at and a % b in the object rem points at (it returns nothing). main calls it with the addresses of two int variables and prints: 17 / 5 = 3 remainder 2 (with the real numbers) and a newline; exit status 0. If there are not exactly two arguments, or b is 0, print a message to standard error and exit with status 1."
crun '17 5'
crun '20 4'
crun '3 7'
crun '-7 2'
crun '5 0'
crun '5'

ctask 3 every2.c "Read the integer arguments (1 to 100) into an int array. Then, WITHOUT square brackets in the loops (use an int pointer p that starts at the array, p < a + n, and *p): print the elements at indexes 0, 2, 4, ... one per line (step the pointer by 2), and then print sum = S where S is the sum of all the elements, and a newline. Exit status 0. With no arguments: usage message to standard error, exit status 1."
crun '10 20 30 40 50'
crun '1 2 3 4'
crun '7'
crun '-1 -1'
crun ''

ctask 4 findlast.c "The first argument is a target integer; the other arguments (1 to 100) are the array. Write int *find_last(int *arr, size_t n, int target) that returns a pointer to the LAST element equal to target, or NULL if there is none (walk the array with a pointer). main prints: 3 found at index 4 (the index is the pointer minus the array, print it with %td) and exits with status 0, or prints: 3 not found and exits with status 1. Fewer than two arguments: usage message to standard error, exit status 1."
crun '3 1 3 5 7 3 9'
crun '3 3'
crun '8 1 2 3'
crun '-1 -1 0 -1 0'
crun '5'
