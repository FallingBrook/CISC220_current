# Day 1: the shell, the filesystem, and commands.
# The sandbox mirrors the tree in the Day 1 lessons:
#
#   (sandbox root, plays the role of /)
#   └── home
#       ├── user1
#       │   ├── animals.txt  fruits.txt  todo.txt  .profile
#       │   └── courses
#       │       ├── CISC204   (a1.txt)
#       │       └── CISC220   (.draft, lab1.sh, notes.txt)
#       └── user2
#           └── courses
#               ├── CISC204   (a2.txt)
#               └── CISC352   (.hidden, readme.txt)
DAY_TITLE="The shell, the filesystem, and commands"

setup_sandbox() {
    mkdir -p home/user1/courses/CISC204 home/user1/courses/CISC220
    mkdir -p home/user2/courses/CISC204 home/user2/courses/CISC352
    printf 'cat\nzebra\ndog\narmadillo\n' > home/user1/animals.txt
    printf 'strawberry\nmango\npineapple\napple\n' > home/user1/fruits.txt
    printf 'buy coffee\nread filesystem notes\n' > home/user1/todo.txt
    echo '# settings' > home/user1/.profile
    echo 'Assignment 1: due Friday' > home/user1/courses/CISC204/a1.txt
    printf '#!/bin/bash\necho "lab 1"\n' > home/user1/courses/CISC220/lab1.sh
    printf 'Week 1: the shell\nWeek 2: the filesystem\nWeek 3: commands\n' > home/user1/courses/CISC220/notes.txt
    echo 'unfinished' > home/user1/courses/CISC220/.draft
    echo 'Assignment 2' > home/user2/courses/CISC204/a2.txt
    echo 'Read me first' > home/user2/courses/CISC352/readme.txt
    echo 'secret' > home/user2/courses/CISC352/.hidden
}

task 1 cmd home/user1 "Print the absolute pathname of the current working directory."
ref 'pwd'

task 2 text . "On the exam, the tree's top directory is the root directory. What is the absolute pathname of the directory CISC352? (Write it as on the exam, starting with /, not with \$SB.)"
accept '/home/user2/courses/CISC352'
accept '/home/user2/courses/CISC352/'

task 3 cmd home "The current working directory is home. Using one command and relative pathnames, list the files in user1's CISC220 directory and in user2's CISC352 directory."
ref 'ls user1/courses/CISC220 user2/courses/CISC352'
compare out

task 4 cmd home/user1/courses/CISC220 "The current working directory is user1's CISC220. Print the contents of readme.txt (in user2's CISC352) using a relative pathname."
ref 'cat ../../../user2/courses/CISC352/readme.txt'
compare out

task 5 cmd home/user2/courses/CISC352 "The current working directory is user2's CISC352. Print the contents of user1's todo.txt using an absolute pathname (write \$SB/home/... where the exam would have /home/...)."
ref 'cat "$SB/home/user1/todo.txt"'
compare out

task 6 cmd home/user1/courses "The current working directory is user1's courses. List all files in CISC220, including hidden files (and the entries . and ..)."
ref 'ls -a CISC220'
compare out

task 7 cmd home/user2/courses "The current working directory is user2's courses. List the hidden and non-hidden files in CISC352, but NOT the entries . and .., one per line."
ref 'ls -A1 CISC352'
compare out

task 8 cmd home/user1/courses "The current working directory is user1's courses. List the files in CISC220 one per line, sorted by size from smallest to largest (hidden files not included)."
ref 'ls -1Sr CISC220'
compare out

task 9 cmd home/user1 "The current working directory is user1. Show a long listing of the directory courses itself, not of the files inside it."
ref 'ls -ld courses'
compare out

task 10 cmd home/user1/courses/CISC204 "The current working directory is user1's CISC204. With one ls command, list the files in the current directory and in user2's CISC204, using . and .. (relative pathnames)."
ref 'ls . ../../../user2/courses/CISC204'
compare out

task 11 cmd home/user2/courses/CISC352 "The current working directory is user2's CISC352. On one line: change into user1's CISC220 using a relative pathname, and only if that succeeds, print the new working directory."
ref 'cd ../../../user1/courses/CISC220 && pwd'
compare out

task 12 cmd home/user1/courses/CISC220 "The current working directory is user1's CISC220. On one line: go up two levels with cd, then print the working directory."
ref 'cd ../..; pwd'
compare out

task 13 cmd home/user1 "Print the contents of fruits.txt followed by the contents of animals.txt, using one command."
ref 'cat fruits.txt animals.txt'
compare out

task 14 cmd home/user1 "Print all the lines of animals.txt and fruits.txt together, in sorted order."
ref 'cat animals.txt fruits.txt | sort'
compare out

task 15 cmd home/user1 "Try to list a directory named backups (it does not exist), then, on the same line, print the exit status of that ls command."
ref 'ls backups; echo $?'
compare out

task 16 cmd home/user1 "On one line: try to change into the directory drafts; if (and only if) that fails, create the directory drafts."
ref 'cd drafts || mkdir drafts'

task 17 cmd home/user1 "With one command, show what kind of command cd is and what kind of command ls is."
ref 'type cd ls'
compare out

task 18 text . "If a command completes without encountering any errors, what is the expected value of its exit status?"
accept '0'

task 19 text . "What single command shows the documentation for the shell built-in cd?"
accept 'help cd'

task 20 text . "What single command shows section 7 of the manual about man?"
accept 'man 7 man'
