# Day 5: arithmetic, arrays, conditional operators, if statements and [[ ]] tests
DAY_TITLE="Arithmetic, arrays, and making decisions"

setup_sandbox() {
    mkdir -p home/user1/notes
    cd home/user1 || return
    printf 'Cade\tBarry\t3100025\nDay\tHolly\t2999999\nFriese\tAndy\t3001111\nYu\tSue\t1990000\n' > classlist
    printf '# student number, last name, first name\n12345,Parr,Jack-Jack\n23456,Wazowski,Mike\n98765,Best,Lucius\n' > students.txt
    echo "some data" > data.txt
    : > empty.txt
    printf '#!/bin/bash\necho hi\n' > run.sh
    chmod 755 run.sh
    echo "my notes" > "my notes.txt"
    echo "draft" > notes/draft.txt
}

# ---------------------------------------------------------------- arithmetic
task 1 cmd home/user1 "On one line: assign 17 to x and 5 to y, then use a single echo with three arithmetic expansions \$(( )) to print the integer quotient x / y, the remainder x % y, and x to the power y, separated by spaces (expected: 3 2 1419857)."
ref 'x=17; y=5; echo $(( x / y )) $(( x % y )) $(( x ** y ))'
compare out

task 2 cmd home/user1 "On one line: assign 7 to n, then use the (( )) command to add 5 to n (no \$ is needed on n inside the double parentheses), then print the value of n (expected: 12)."
ref 'n=7; (( n += 5 )); echo "$n"'
compare out

task 3 cmd home/user1 "The file classlist has one line per student. Print the number of students multiplied by 3, using an arithmetic expansion \$(( )) around a command substitution that runs wc -l < classlist (expected: 12)."
ref 'echo $(( $(wc -l < classlist) * 3 ))'
compare out

task 4 text . "After running the command (( 4 - 4 )), what is the value of \$? (its exit status)?"
accept '1'

# ---------------------------------------------------------------- arrays
task 5 cmd home/user1 "Start your line with arr=(red green blue); then append the value yellow to the end of arr as a new element, then print all the elements of arr on one line (expected: red green blue yellow)."
ref 'arr=(red green blue); arr+=(yellow); echo "${arr[@]}"'
compare out

task 6 cmd home/user1 "Start your line with arr=([2]=x [5]=y [9]=z); then print, on one line, the list of indexes that arr uses. Use an array expansion; do not just type echo 2 5 9."
ref 'arr=([2]=x [5]=y [9]=z); echo "${!arr[@]}"'
compare out

task 7 cmd home/user1 "Use mapfile to read the lines of students.txt into an array named lines (remove the newlines with -t), then print the number of elements in the array. Write both commands on one line separated by ; (expected: 4)."
ref 'mapfile -t lines < students.txt; echo "${#lines[@]}"'
compare out

task 8 cmd home/user1 "Use mapfile to read the lines of students.txt into an array named s, then print only the element at index 2 (the third line of the file, which is Mike's line). One line, two commands separated by ;"
ref 'mapfile -t s < students.txt; echo "${s[2]}"'
compare out

task 9 text . "Write the expansion that gives the number of elements in the array arr."
accept '${#arr[@]}'
accept '${#arr[*]}'
accept '"${#arr[@]}"'

# ---------------------------------------------------------------- tests and if
task 10 text . "Which [[ ]] file test operator is true if the file exists and has a size greater than zero? (answer like: -x)"
accept '-s'

task 11 text . "What does this print?   [[ 100 < 2 ]]; echo \$?"
accept '0'

task 12 cmd home/user1 "Start your line with f=empty.txt; then write a one-line if statement that prints empty if the file named in f has size zero, and prints not empty otherwise (use a [[ ]] file test on \$f, with else)."
ref 'f=empty.txt; if [[ ! -s $f ]]; then echo empty; else echo "not empty"; fi'
compare out

# ---------------------------------------------------------------- scripts
task 13 script home/user1 "Write calc.sh A B. If it does not get exactly 2 arguments it prints Usage: calc.sh a b to standard error and exits with status 1. Otherwise it prints five lines in this exact form (shown for 17 and 5): 17 + 5 = 22, 17 - 5 = 12, 17 * 5 = 85, 17 / 5 = 3, 17 % 5 = 2 (integer arithmetic) and exits with status 0."
file calc.sh
run './calc.sh 17 5; echo "exit=$?"'
run './calc.sh -7 2; echo "exit=$?"'
run './calc.sh; echo "exit=$?"'
run './calc.sh 1 2 3; echo "exit=$?"'

task 14 script home/user1 "Write iseven.sh N (from the arithmetic notebook). It prints nothing. It exits with status 0 if N is even and with status 1 if N is odd. With no argument it exits with status 0."
file iseven.sh
run './iseven.sh 4; echo $?'
run './iseven.sh 7; echo $?'
run './iseven.sh 0; echo $?'
run './iseven.sh; echo $?'
run './iseven.sh -3; echo $?'

task 15 script home/user1 "Write swapends.sh ARG... It copies its command line arguments into an array, swaps the first and the last element, and prints all the elements on one line separated by single spaces. Example: ./swapends.sh a \"b c\" d e prints e b c d a. With fewer than 2 arguments it prints Usage: swapends.sh arg1 arg2 ... to standard error and exits with status 1. No loop is needed."
file swapends.sh
run './swapends.sh a "b c" d e; echo "exit=$?"'
run './swapends.sh x y'
run './swapends.sh "first one" 2 "last one"'
run './swapends.sh only; echo "exit=$?"'
run './swapends.sh; echo "exit=$?"'

task 16 script home/user1 "Write filetype.sh FILE. If FILE does not exist print: FILE does not exist to standard error and exit with status 1. If it is a directory print: FILE is a directory. If it is a regular file print: FILE is a regular file (or: FILE is an empty regular file when its size is zero), and then, only for a regular file that is executable, also print: FILE is executable. Exit status 0 when FILE exists. (Sandbox: notes is a directory, data.txt has text, empty.txt is empty, run.sh is executable.)"
file filetype.sh
run './filetype.sh notes; echo "exit=$?"'
run './filetype.sh data.txt; echo "exit=$?"'
run './filetype.sh empty.txt; echo "exit=$?"'
run './filetype.sh run.sh; echo "exit=$?"'
run './filetype.sh "my notes.txt"; echo "exit=$?"'
run './filetype.sh nothere.txt; echo "exit=$?"'

task 17 script home/user1 "Write safecreate.sh NAME (like the course's namedsh.sh). If the number of arguments is not exactly 1, print: safecreate.sh: filename required to standard error and exit with status 2. If a file named NAME already exists, print: safecreate.sh: NAME already exists to standard error and exit with status 1 (do not change the file). Otherwise create NAME containing the single line #!/bin/bash and give the owner execute permission (keep the other permission bits as created)."
file safecreate.sh
run './safecreate.sh new.sh; echo "exit=$?"; cat new.sh'
run './safecreate.sh "my script.sh"; echo "exit=$?"; cat "my script.sh"'
run './safecreate.sh data.txt; echo "exit=$?"; cat data.txt'
run './safecreate.sh notes; echo "exit=$?"'
run './safecreate.sh; echo "exit=$?"'
run './safecreate.sh a b; echo "exit=$?"'

task 18 script home/user1 "Write leap.sh YEAR. If the number of arguments is not 1, print: Usage: leap.sh year to standard error, exit 1. If YEAR is not made only of digits, print: leap.sh: YEAR is not a year to standard error, exit 2. Otherwise print YEAR is a leap year or YEAR is not a leap year (exit 0). A year is a leap year if it is divisible by 400, or divisible by 4 and not divisible by 100."
file leap.sh
run './leap.sh 2000; ./leap.sh 2024; ./leap.sh 1900; ./leap.sh 2023; echo "exit=$?"'
run './leap.sh 20x4; echo "exit=$?"'
run './leap.sh; echo "exit=$?"'
run './leap.sh 2000 2001; echo "exit=$?"'

task 19 script home/user1 "Write grade.sh MARK. If the number of arguments is not 1, print: Usage: grade.sh mark to standard error, exit 1. If MARK is not made only of digits, or is greater than 100, print: grade.sh: mark must be an integer from 0 to 100 to standard error, exit 2. Otherwise print the letter: A for 80-100, B for 70-79, C for 60-69, D for 50-59, F below 50 (exit 0)."
file grade.sh
run './grade.sh 100; ./grade.sh 80; ./grade.sh 79; ./grade.sh 70; echo "exit=$?"'
run './grade.sh 69; ./grade.sh 60; ./grade.sh 55; ./grade.sh 50; ./grade.sh 49; ./grade.sh 0'
run './grade.sh 101; echo "exit=$?"'
run './grade.sh -5; echo "exit=$?"'
run './grade.sh 7a; echo "exit=$?"'
run './grade.sh; echo "exit=$?"'
run './grade.sh 50 60; echo "exit=$?"'

task 20 script home/user1 "Write testpw.sh PASSWORD (Assignment 3 Q1). No arguments: print Usage: testpw.sh password to standard error, exit 1 (extra arguments are ignored). Check IN THIS ORDER and print the message to standard error for EVERY failed rule: (1) password cannot contain whitespace (2) password length less than 8 (3) password must contain at least one letter (4) password must contain at least one digit (5) password must contain at least one symbol. Exit 2 if any rule failed, else print nothing and exit 0. Hint: [[:space:]] [[:alpha:]] [[:digit:]] [[:punct:]] with =~, and \${#pw} for the length."
file testpw.sh
run './testpw.sh "abc123!@"; echo "exit=$?"'
run './testpw.sh abc; echo "exit=$?"'
run './testpw.sh "pass word 1!"; echo "exit=$?"'
run './testpw.sh 12345678; echo "exit=$?"'
run './testpw.sh "        "; echo "exit=$?"'
run './testpw.sh abcdefgh1 ignored; echo "exit=$?"'
run './testpw.sh; echo "exit=$?"'
