# Day 25 labs: a generic stack: void * elements, pointers to functions, removing nodes
DAY_TITLE="A generic stack: void * elements, function pointers, removing a node"

ctask 1 pickprint.c "The first argument is one letter: i, d or s. Write three functions with the same type, void print_int(const void *elem), void print_double(const void *elem) and void print_string(const void *elem), and a typedef print_func for a pointer to such a function. main chooses ONE function according to the letter and stores it in a print_func variable f. Then for every other argument it calls f with the address of the value: for i, convert with atoi into an int variable and pass its address (print_int prints it with %d); for d, convert with atof into a double variable (print_double prints it with %.2f); for s, pass argv[i] itself (print_string prints it inside double quotes, like \"abc\"). Each value is printed on its own line. Exit status 0 (no values after the letter is fine: print nothing). With no arguments, or a first argument that is not exactly one of the letters i, d, s: usage message to standard error, exit status 1."
crun 'i 7 -3 42'
crun 'd 2.5 -0.5 10'
crun 's hello "two words" x'
crun 'd'
crun 'x 1 2'
crun 'ii 1'
crun ''

ctask 2 gstack.c "Write a generic stack in this one file, like the notebook's qlgstack: struct node { void *elem; struct node *next; } and a stack struct with top and size. Write push, pop (it frees the node and gives back the element pointer), a print function that takes a pointer to a function void (*)(const void *) and prints the notebook's format top : c, b, a : bottom (elements separated by a comma and a space, then a newline), and a free function that takes a pointer to a function void (*)(void *) and calls it on every element before freeing each node. main pushes a heap COPY of each argument (malloc strlen + 1, then strcpy), prints the stack, pops the top element and prints: popped c, size 2 (the word and the new size) and a newline, frees that word, prints the stack again, and finally frees the stack and its words. An empty stack prints as top :  : bottom (two spaces). Exit status 0. With no arguments: usage message to standard error, exit status 1. (Run your program with valgrind too: it should report 0 bytes in use at exit.)"
crun 'a b c'
crun 'x'
crun 'stack of words here'
crun ''

ctask 3 removeval.c "The first argument is a target integer; the other arguments (zero or more) are integers. Build a singly linked list of struct node { int elem; struct node *next; } in the SAME order as the arguments (each node from malloc). Then remove EVERY node whose elem equals the target, freeing each removed node (keep a prev pointer; remember the head may be removed, even several times in a row). Print removed N (the number of nodes removed) and a newline, then the remaining list as [1,2,3] (no spaces; an empty list is []) and a newline. Free the list; exit status 0. With no arguments: usage message to standard error, exit status 1."
crun '3 3 1 3 3 2 3'
crun '5 1 2 3'
crun '4 4 4 4'
crun '0'
crun '-1 7 -1 8'
crun ''

ctask 4 removeat.c "The first argument is an index k; the other arguments (zero or more) are integers. Build a singly linked list in argument order (malloc each node), then remove the node at index k (0 is the first node): walk with prev and cur, unlink cur (if it is the head, the head changes), print removed V (its elem) and a newline, free it, print the list as [5,6] and a newline, free the list and exit with status 0. If k is negative or there is no node at index k, print no node at index K and a newline, then the unchanged list, free it, and exit with status 1. With no arguments: usage message to standard error, exit status 1."
crun '0 5 6 7'
crun '1 5 6 7'
crun '2 5 6 7'
crun '3 5 6 7'
crun '0 9'
crun '-1 1 2'
crun ''
