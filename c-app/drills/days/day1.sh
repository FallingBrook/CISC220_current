# Day 1 labs: your first C program (printf, puts, return value of main). No command line arguments are used
# today: every test runs your program with different arguments only to check that it ignores them.
DAY_TITLE="Your first C program"

ctask 1 hello.c "Print exactly these two lines and exit with status 0:
Hello, CISC220!
C is compiled, not interpreted.
Compile and run it yourself first: gcc -Wall -o hello hello.c && ./hello"
crun ''
crun 'extra'
crun 'a b c'

ctask 2 status.c "Print the line
Something went wrong.
(one line, ending with a newline) and make the program exit with status 4. Check it yourself with: ./status; echo \$?"
crun ''
crun 'x'
crun '"two words"'

ctask 3 tree.c "Print this small tree exactly (each line ends with a newline, no spaces after the last character), then exit with status 0:
    *
   ***
  *****
 *******
    |
The star rows have 4, 3, 2 and 1 leading spaces, and the trunk has 4."
crun ''
crun 'big'
crun '1 2'
