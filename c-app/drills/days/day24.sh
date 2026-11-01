# Day 24 labs: a linked stack, part 2: pop, print, free (and no leaks)
DAY_TITLE="A linked stack, part 2: pop, print and free"

ctask 1 popall.c "Write the linked stack in this one file: struct node (an int elem and a struct node *next), a stack struct with a top pointer and a size_t size, a function that makes an empty stack on the heap, push (malloc a node, check it), pop (save the top element, unlink the top node, subtract 1 from the size, free the node, give back the element) and a free function that frees every node and then the stack struct. main pushes every command line argument (converted with atoi), first argument first. Then, while the stack is not empty, it pops one element and prints the line popped X, size N (N is the size after the pop). Finally it prints empty, frees the stack and exits with status 0 (also with no arguments, which prints only empty). Check it with valgrind --leak-check=full: it must say All heap blocks were freed."
crun '1 2 3'
crun ''
crun '42'
crun '-1 0 1 2'

ctask 2 stackops.c "Same stack as task 1, plus a print function. The command line arguments are commands, done from left to right: the word pop pops the top element and prints popped X; the word print prints the stack from the top to the bottom in the notebook's format, for example top : 3, 2, 1 : bottom (an empty stack prints top :  : bottom, with two spaces between the colons); anything else is a number (atoi) to push. After the last argument print size N, free the stack and exit with status 0. If pop is given when the stack is empty, print an error message to standard error, FREE THE STACK, and exit with status 1 (do not pop from an empty stack: that is undefined behaviour)."
crun '1 2 print pop print'
crun 'print'
crun 'pop'
crun '5 pop pop'
crun '7 8 9 pop 10 print'
crun ''

ctask 3 rpn.c "A postfix calculator with a linked stack. Each command line argument is either an operator (+, - or x for multiply; x because * would be expanded by the shell) or a number (atoi). A number is pushed. An operator pops the top element b, then pops a, and pushes a + b, a - b or a * b (careful: the top is the RIGHT operand). If an operator finds fewer than two elements, print an error message to standard error, free the stack and exit with status 1. At the end there must be exactly one element: print it on its own line, free the stack and exit with status 0; otherwise (no element, or more than one) print an error message to standard error, free the stack and exit with status 1."
crun '3 4 +'
crun '5 1 2 + 4 x + 3 -'
crun '2 3 -'
crun '7'
crun '+'
crun '1 +'
crun '1 2'
crun ''

ctask 4 reverse.c "Use two linked stacks a and b (same code as task 2). Push every command line argument (atoi) onto a, first argument first, and print the line a: followed by a's print (for example a: top : 3, 2, 1 : bottom). Then move every element from a to b: pop it from a and push it onto b, until a is empty. Print moved N (how many elements were moved), then the lines a: ... and b: ... in the same format. Free BOTH stacks and exit with status 0."
crun '1 2 3'
crun ''
crun '9'
crun '4 -4 0 10'
