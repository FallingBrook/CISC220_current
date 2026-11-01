# Day 14 labs: arrays in depth
DAY_TITLE="Arrays in depth: algorithms, copying and 2D arrays"

ctask 1 rev.c "Read the integer command line arguments (1 to 100 of them) into an int array with atoi. Write void reverse(int n, int a[n]) that reverses the array IN PLACE (swap the first and last elements, then the second and second-to-last, and so on; no second array). main calls it and prints the reversed array on one line: the values separated by single spaces (no space after the last one), then a newline. Exit status 0. With no arguments (or more than 100): usage message to standard error, exit status 1."
crun '1 2 3 4'
crun '5 6 7'
crun '42'
crun '-3 0 -3 9 8 1'
crun ''

ctask 2 ssort.c "Read the integer arguments (1 to 100) into an int array. Sort it into increasing order with SELECTION SORT: for j = 0, 1, ..., n-2, find the index idx of the smallest element from index j to the end (write int minidx(int n, const int a[n], int start); take the first one if there is a tie) and swap a[j] with a[idx] (even when idx == j). After each pass print: pass 0: 0 1 3 4 2 (the pass number j, a colon, a space, then the whole array separated by single spaces). At the end print: sorted: 0 1 2 3 4. Exit status 0. With no arguments: usage message to standard error, exit status 1."
crun '0 3 1 4 2'
crun '5 4 3 2 1'
crun '7'
crun '2 -1 2 -1'
crun '1 2 3'
crun ''

ctask 3 table.c "The program gets two arguments, rows and cols, each from 1 to 10. Store a multiplication table in a 2D array int m[10][10] with m[i][j] = (i + 1) * (j + 1), then print the first rows rows and cols columns, each value with printf(\"%4d\", ...) and a newline after each row. Then print: total = S (the sum of the printed values) and a newline. Exit status 0. Not exactly two arguments, or a value outside 1 to 10: message to standard error, exit status 1."
crun '3 4'
crun '1 1'
crun '10 10'
crun '2 5'
crun '0 3'
crun '4 11'
crun '3'

ctask 4 rotate.c "The first argument is k (0 or more); the other arguments (1 to 100 integers) are the array. Rotate the array LEFT by k places: the element at index k%n moves to index 0, and elements that fall off the front come back at the end (so 2 rotating 1 2 3 4 5 gives 3 4 5 1 2). Copy into a second array element by element, then copy back into the first array, then print the first array: values separated by single spaces, newline, exit status 0. Fewer than two arguments or a negative k: message to standard error, exit status 1."
crun '2 1 2 3 4 5'
crun '0 7 8 9'
crun '7 1 2 3'
crun '1 42'
crun '3 1 2 3'
crun '-1 1 2'
crun '4'
