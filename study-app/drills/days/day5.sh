# Day 5: regular expressions, grep, [[ ]] tests, if statements
DAY_TITLE="Regular expressions and making decisions"

setup_sandbox() {
    mkdir -p home/user1/notes
    cd home/user1 || return
    printf '%s\n' apple Banana cherry date fig kiwi x-ray a Apple2 2cool \
        color colour colouur colr sing singing zebra mississippi r2d2 yes \
        'hello world' > words.txt
    printf '%s\n' 'INFO server started' 'WARN disk 85% full' 'ERROR cannot open config.txt' \
        'INFO user1 logged in' 'error: this line is lowercase' 'WARN memory low' \
        'ERROR disk full' 'INFO done' > log.txt
    printf '%s\n' 'Barry Cade 613-555-0101' 'Holly Day 6135550199' 'Andy Friese 343-555-0123' \
        'Sue Yu 613-55-01234' 'Office (613) 555-0100' > phones.txt
    echo "some data" > data.txt
    : > empty.txt
    printf '#!/bin/bash\necho hi\n' > run.sh
    chmod 755 run.sh
    echo "my notes" > "my notes.txt"
    echo "draft" > notes/draft.txt
}

# ---------------------------------------------------------------- grep -E
task 1 cmd home/user1 "words.txt has one word per line. Use grep -E to print the lines of words.txt that start with the letter s."
ref 'grep -E "^s" words.txt'
compare out

task 2 cmd home/user1 "Print the lines of words.txt that end with the letter y."
ref 'grep -E "y$" words.txt'
compare out

task 3 cmd home/user1 "Using ONE regular expression with the ? metacharacter, print the lines of words.txt that are exactly color or exactly colour (nothing else on the line)."
ref 'grep -E "^colou?r$" words.txt'
compare out

task 4 cmd home/user1 "Print the lines of words.txt that contain at least one digit."
ref 'grep -E "[[:digit:]]" words.txt'
compare out

task 5 cmd home/user1 "Print the lines of words.txt that are exactly 4 characters long."
ref 'grep -E "^....$" words.txt'
compare out

task 6 cmd home/user1 "Print the lines of words.txt that start with a lowercase letter AND end with a lowercase letter (anything may be in between, and a one-letter line such as a counts). Assume LC_ALL=C."
ref 'grep -E "^[a-z](.*[a-z])?$" words.txt'
compare out

task 7 cmd home/user1 "Print the lines of words.txt that consist ONLY of lowercase letters (at least one). Compare your output with task 6: which words differ, and why? Assume LC_ALL=C."
ref 'grep -E "^[a-z]+$" words.txt'
compare out

task 8 cmd home/user1 "Print the lines of log.txt that contain ERROR (uppercase), each preceded by its line number."
ref 'grep -En ERROR log.txt'
compare out

task 9 cmd home/user1 "Print the lines of log.txt that contain the word error in any mix of upper and lower case."
ref 'grep -Ei error log.txt'
compare out

task 10 cmd home/user1 "Using ONE regular expression with the choice operator |, print the lines of log.txt that start with ERROR or start with WARN."
ref 'grep -E "^(ERROR|WARN)" log.txt'
compare out

task 11 cmd home/user1 "phones.txt has one contact per line. Print the lines that contain a phone number written as 3 digits, a dash, 3 digits, a dash, 4 digits (like 613-555-0101). Use the {n} quantifier."
ref 'grep -E "[0-9]{3}-[0-9]{3}-[0-9]{4}" phones.txt'
compare out

# ---------------------------------------------------------------- short answers
task 12 text . "Which [[ ]] file operator is true if the file exists and has a size greater than zero? (answer like: -x)"
accept '-s'

task 13 text . "What does this print?   [[ 100 < 2 ]]; echo \$?"
accept '0'

# ---------------------------------------------------------------- scripts
task 14 script home/user1 "Write isint.sh. With exactly one argument: if the argument is a signed or unsigned integer (optional + or - then one or more digits, nothing else), print: VALUE is an integer (exit status 0); otherwise print: VALUE is not an integer (to standard output) and exit with status 2. With any other number of arguments print: Usage: isint.sh value to standard error and exit with status 1."
file isint.sh
run './isint.sh 42; echo "exit=$?"'
run './isint.sh -7; echo "exit=$?"'
run './isint.sh +13; echo "exit=$?"'
run './isint.sh 4x2; echo "exit=$?"'
run './isint.sh "1 2"; echo "exit=$?"'
run './isint.sh -; echo "exit=$?"'
run './isint.sh; echo "exit=$?"'
run './isint.sh 1 2; echo "exit=$?"'

task 15 script home/user1 "Write filetype.sh FILE. If FILE does not exist print: FILE does not exist to standard error and exit with status 1. If it is a directory print: FILE is a directory. If it is a regular file print: FILE is a regular file (or: FILE is an empty regular file when its size is zero), and then, only for a regular file that is executable, also print: FILE is executable. Exit status 0 when FILE exists. (Sandbox: notes is a directory, data.txt has text, empty.txt is empty, run.sh is executable.)"
file filetype.sh
run './filetype.sh notes; echo "exit=$?"'
run './filetype.sh data.txt; echo "exit=$?"'
run './filetype.sh empty.txt; echo "exit=$?"'
run './filetype.sh run.sh; echo "exit=$?"'
run './filetype.sh "my notes.txt"; echo "exit=$?"'
run './filetype.sh nothere.txt; echo "exit=$?"'

task 16 script home/user1 "Write safecreate.sh NAME (like the course's namedsh.sh). If the number of arguments is not exactly 1, print: safecreate.sh: filename required to standard error and exit with status 2. If a file named NAME already exists, print: safecreate.sh: NAME already exists to standard error and exit with status 1 (do not change the file). Otherwise create NAME containing the single line #!/bin/bash and give the owner execute permission (keep the other permission bits as created)."
file safecreate.sh
run './safecreate.sh new.sh; echo "exit=$?"; cat new.sh'
run './safecreate.sh "my script.sh"; echo "exit=$?"; cat "my script.sh"'
run './safecreate.sh data.txt; echo "exit=$?"; cat data.txt'
run './safecreate.sh notes; echo "exit=$?"'
run './safecreate.sh; echo "exit=$?"'
run './safecreate.sh a b; echo "exit=$?"'

task 17 script home/user1 "Write grade.sh MARK. If the number of arguments is not 1, print: Usage: grade.sh mark to standard error, exit 1. If MARK is not made only of digits, or is greater than 100, print: grade.sh: mark must be an integer from 0 to 100 to standard error, exit 2. Otherwise print the letter: A for 80-100, B for 70-79, C for 60-69, D for 50-59, F below 50 (exit 0)."
file grade.sh
run './grade.sh 100; ./grade.sh 80; ./grade.sh 79; ./grade.sh 70; echo "exit=$?"'
run './grade.sh 69; ./grade.sh 60; ./grade.sh 55; ./grade.sh 50; ./grade.sh 49; ./grade.sh 0'
run './grade.sh 101; echo "exit=$?"'
run './grade.sh -5; echo "exit=$?"'
run './grade.sh 7a; echo "exit=$?"'
run './grade.sh; echo "exit=$?"'
run './grade.sh 50 60; echo "exit=$?"'

task 18 script home/user1 "Write leap.sh YEAR. If the number of arguments is not 1, print: Usage: leap.sh year to standard error, exit 1. If YEAR is not made only of digits, print: leap.sh: YEAR is not a year to standard error, exit 2. Otherwise print YEAR is a leap year or YEAR is not a leap year (exit 0). A year is a leap year if it is divisible by 400, or divisible by 4 and not divisible by 100."
file leap.sh
run './leap.sh 2000; ./leap.sh 2024; ./leap.sh 1900; ./leap.sh 2023; echo "exit=$?"'
run './leap.sh 20x4; echo "exit=$?"'
run './leap.sh; echo "exit=$?"'
run './leap.sh 2000 2001; echo "exit=$?"'

task 19 script home/user1 "Write checkuser.sh USERNAME. No arguments: print Usage: checkuser.sh username to standard error, exit 1 (extra arguments are ignored). Check these rules IN THIS ORDER; for EVERY rule that fails print its message to standard error: (1) username cannot contain whitespace (2) username length must be from 3 to 12 (3) username must start with a lowercase letter (4) username cannot contain uppercase letters (5) username must contain at least one digit. Exit 2 if any rule failed; if all pass print nothing and exit 0."
file checkuser.sh
run './checkuser.sh jsmith42; echo "exit=$?"'
run './checkuser.sh ab1; echo "exit=$?"'
run './checkuser.sh "j smith 1"; echo "exit=$?"'
run './checkuser.sh "J Smith"; echo "exit=$?"'
run './checkuser.sh Ab; echo "exit=$?"'
run './checkuser.sh 9lives; echo "exit=$?"'
run './checkuser.sh averyveryverylongname1; echo "exit=$?"'
run './checkuser.sh jSmith7 extra; echo "exit=$?"'
run './checkuser.sh ""; echo "exit=$?"'
run './checkuser.sh; echo "exit=$?"'

task 20 script home/user1 "Write testpw.sh PASSWORD (Assignment 3 Q1). No arguments: print Usage: testpw.sh password to standard error, exit 1 (extra arguments are ignored). Check IN THIS ORDER and print the message to standard error for EVERY failed rule: (1) password cannot contain whitespace (2) password length less than 8 (3) password must contain at least one letter (4) password must contain at least one digit (5) password must contain at least one symbol. Exit 2 if any rule failed, else print nothing and exit 0. Hint: [[:space:]] [[:alpha:]] [[:digit:]] [[:punct:]] with =~."
file testpw.sh
run './testpw.sh "abc123!@"; echo "exit=$?"'
run './testpw.sh abc; echo "exit=$?"'
run './testpw.sh "pass word 1!"; echo "exit=$?"'
run './testpw.sh 12345678; echo "exit=$?"'
run './testpw.sh "        "; echo "exit=$?"'
run './testpw.sh abcdefgh1 ignored; echo "exit=$?"'
run './testpw.sh; echo "exit=$?"'
