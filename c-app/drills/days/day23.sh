# Day 23 labs: a linked stack, part 1: nodes, the stack struct, new and push
DAY_TITLE="A linked stack, part 1: nodes, the stack struct and push"

ctask 1 revstack.c "Define struct node (an int elem and a struct node *next) and a stack struct holding a pointer to the top node and a size_t size, as in today's lessons. Write a function that makes a new empty stack on the heap and a push function that mallocs a node and links it in at the top (check every malloc for NULL). main makes a stack and pushes every command line argument (converted with atoi) in order, first argument first. Then it prints the line size N, followed by the elements from the top of the stack to the bottom, one per line, by following the next pointers. Exit status 0 (also with no arguments, which prints just size 0). Do not use an array: the elements must be stored in nodes."
crun '1 2 3'
crun '42'
crun ''
crun '-5 0 7 100'

ctask 2 peek.c "Same stack as task 1. Push every command line argument (atoi), first argument first. Then, WITHOUT removing anything, print three lines: top: X where X is the element in the top node, below top: Y where Y is the element in the node right below the top, and size: N. When there is no such node print none instead of the number (for example top: none). Reach the nodes only through the stack's top pointer and the next pointers. Exit status 0."
crun ''
crun '8'
crun '1 2 3'
crun '4 -4'

ctask 3 digits.c "The program gets exactly one argument, a non-negative integer n (use atoi). Using a linked stack like task 1, push the digits of n starting with the LAST digit (n % 10, then divide n by 10, and so on), so the first digit ends up on top; for n = 0 push a single 0. Then walk from the top node to the bottom and print the digits on one line separated by single spaces (no space at the end), then a second line pushed K nodes where K is the stack's size. With no argument, more than one, or a negative n: print a message to standard error and exit with status 1."
crun '1234'
crun '0'
crun '7'
crun '1000'
crun ''
crun '-5'
crun '1 2'

ctask 4 insert2.c "The first argument is a value v; the other arguments are elements. Using a linked stack like task 1, push the elements (atoi) in order, first one first. Then write and call a function int insert_second(struct stack *s, int elem) that mallocs a new node holding v and links it in as the SECOND node, right below the top (do not change the top node), adds one to the size, and returns 1; if the stack is empty (or malloc fails) it changes nothing and returns 0. If it returns 0, print a message to standard error and exit with status 1. Otherwise print the elements from top to bottom on one line separated by single spaces, then the line size N. With no arguments at all: usage message to standard error, exit status 1."
crun '9 1 2 3'
crun '0 5'
crun '-1 10 20'
crun '7'
crun ''
