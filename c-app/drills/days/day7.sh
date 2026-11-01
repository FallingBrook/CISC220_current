# Day 7 labs: scope and lifetime
DAY_TITLE="Scope and lifetime"

ctask 1 ids.c "Write ids.c. Write a function int next_id(void) that returns 1 the first time it is called, 2 the second time, and so on, using a static local variable (no global variables). main prints one line per command line argument: the next id, a colon, a space, and the argument, e.g. ./ids apple pear prints 1: apple then 2: pear. Exit status 0. With no arguments, print a usage message such as Usage: ids word ... to standard error and exit with status 1."
crun 'apple pear'
crun 'one'
crun 'a b c d e f g h i j k l'
crun '"two words" x'
crun ''

ctask 2 runmax.c "Write runmax.c. Write a function int running_max(int x) that returns the largest value it has been given so far, including x, using static local variables (no globals). Careful: the numbers can be negative, so do not start the maximum at 0; remember whether this is the first call instead. main converts each command line argument with atoi (from <stdlib.h>) and prints the number and the running maximum on one line, separated by a space. With no arguments it prints nothing. Exit status 0. Example: ./runmax 3 1 4 prints 3 3, then 1 3, then 4 4."
crun '3 1 4 1 5'
crun '-5 -2 -9'
crun '7'
crun '0 -1 0 2'
crun ''

ctask 3 calls.c "Write calls.c. Declare a global variable unsigned int calls = 0; and a function int cube(int x) that returns x * x * x and adds 1 to calls every time it runs. main converts each command line argument with atoi and prints cube(x) = result, e.g. cube(2) = 8, one line per argument; at the end it prints cube was called N times (N is the global counter). With no arguments it prints only cube was called 0 times. Exit status 0."
crun '2 -3'
crun '0 1 10'
crun '5'
crun ''

ctask 4 sums.c "Write sums.c, the notebook's suggested fix for sum_of2_fails.c. Write unsigned int sum_of(unsigned int n) that returns 0 + 1 + ... + n using a LOCAL running total (not a global or static variable), so calling it twice with the same n gives the same answer. main converts each command line argument with atoi (assume each is 0 or more) and prints sum_of(n) = s, one line per argument, with %u. With no arguments, print a usage message such as Usage: sums n ... to standard error and exit with status 1. Example: ./sums 10 10 prints sum_of(10) = 55 twice."
crun '10 10'
crun '3 0 4'
crun '100'
crun '1 1 1'
crun ''
