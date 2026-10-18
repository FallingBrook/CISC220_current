# Day 4: writing scripts: arguments, variables, strings, arithmetic
DAY_TITLE="Writing scripts: arguments, variables, strings, arithmetic"

setup_sandbox() {
    mkdir -p home/user1/somedir home/user1/courses/CISC220
    cd home/user1 || return
    echo "alpha" > a.txt
    echo "bravo" > b.txt
    echo "private notes" > "my notes.txt"
    echo "copy me" > "copy target.txt"
    echo "junk" > myfile
    echo "old draft" > somedir/myfile
    echo "spaced out" > "somedir/my file"
    echo "report" > report.txt
    echo "lab one" > "lab 1.txt"
    echo "tarball" > archive.tar.gz
    echo "abcdefgh" > word.txt
    printf 'Cade\tBarry\t3100025\nDay\tHolly\t2999999\nFriese\tAndy\t3001111\nYu\tSue\t1990000\n' > classlist
    chmod 640 a.txt
    chmod 644 b.txt "copy target.txt"
    chmod 600 "my notes.txt"
    chmod 755 somedir
}

task 1 cmd home/user1 "Using command substitution, store the octal permissions of a.txt (stat -c %a a.txt prints them) in a variable named perm, then print the value of perm. Write it all on one line, separating the two commands with a semicolon."
ref 'perm=$(stat -c %a a.txt); echo "$perm"'
compare out

task 2 cmd home/user1 "In a single command, give b.txt exactly the same permissions as a.txt. Use chmod together with a command substitution that runs stat -c %a."
ref 'chmod "$(stat -c %a a.txt)" b.txt'

task 3 cmd home/user1 "On one line: store the pathname /home/user1/courses/CISC220/notes.txt in a variable p, then print only its directory part (/home/user1/courses/CISC220) using a parameter expansion that removes the shortest trailing part matching /*."
ref 'p=/home/user1/courses/CISC220/notes.txt; echo "${p%/*}"'
compare out

task 4 cmd home/user1 "On one line: store the filename archive.tar.gz in a variable f, then use mv and the expansion \${f%.*} to rename the file archive.tar.gz so that its last extension is removed (the new name is archive.tar)."
ref 'f=archive.tar.gz; mv "$f" "${f%.*}"'

task 5 cmd home/user1 "On one line: store the filename 'lab 1.txt' (it contains a space) in a variable f, then rename that file so every space in its name becomes an underscore (new name lab_1.txt). Use the replace-all expansion \${f//pattern/replacement}."
ref 'f="lab 1.txt"; mv "$f" "${f// /_}"'

task 6 cmd home/user1 "On one line: store the contents of word.txt in a variable s (use command substitution with cat), then print the first half of s using \${s:offset:length} and \${#s} (word.txt holds an 8-character word, so 4 characters are printed)."
ref 's=$(cat word.txt); echo "${s:0:${#s}/2}"'
compare out

task 7 cmd home/user1 "The file classlist has one line per student. Print the number of students multiplied by 3, using arithmetic expansion \$(( )) around a command substitution that runs wc -l < classlist."
ref 'echo $(( $(wc -l < classlist) * 3 ))'
compare out

task 8 cmd home/user1 "On one line: assign 17 to x and 5 to y, then use a single echo with three arithmetic expansions to print the integer quotient, the remainder, and x to the power y, separated by spaces (expected: 3 2 1419857)."
ref 'x=17; y=5; echo $(( x / y )) $(( x % y )) $(( x ** y ))'
compare out

task 9 text . "Inside a script, which special parameter holds the number of command line arguments? (write it the way you would use it, with the dollar sign)"
accept '$#'
accept '${#}'

task 10 text . "Inside a script, how do you get the value of the twelfth command line argument? (write the expansion)"
accept '${12}'

task 11 text . "After running (( 4 - 4 )), what is the value of \$? ?"
accept '1'

task 12 script home/user1 "Write copyperm.sh SRC DEST (Quiz 1, Q4): it sets the permissions of file DEST to be equal to the permissions of file SRC. Use stat -c %a and chmod. It prints nothing. Filenames can contain spaces, so quote your variables."
file copyperm.sh
run './copyperm.sh a.txt b.txt; stat -c %a b.txt'
run './copyperm.sh "my notes.txt" "copy target.txt"; stat -c %a "copy target.txt"'
run './copyperm.sh somedir b.txt; stat -c %a b.txt'

task 13 script home/user1 "Write trash.sh PATHNAME (Quiz 1, Q5). PATHNAME always contains a /. The script (1) finds the directory dir that the file is in, (2) creates the directory dir/.trash, (3) sets the permissions of .trash to rwx for the owner and nothing for anyone else, (4) prints: moving PATHNAME to the trashcan (5) moves the file into .trash."
file trash.sh
run './trash.sh ./myfile; ls -A; ls -A .trash; stat -c %a .trash'
run './trash.sh "somedir/my file"; ls -A somedir somedir/.trash'
run './trash.sh "$SB/home/user1/somedir/myfile"; ls -A somedir/.trash'

task 14 script home/user1 "Write newext.sh FILE EXT that renames FILE so that its last extension is replaced by EXT. Example: ./newext.sh report.txt md renames report.txt to report.md; ./newext.sh archive.tar.gz zip renames it to archive.tar.zip. Use mv and \${f%.*}. Print nothing. Names may contain spaces."
file newext.sh
run './newext.sh report.txt md; ls'
run './newext.sh archive.tar.gz zip; ls'
run './newext.sh "lab 1.txt" text; ls'

task 15 script home/user1 "Write halves.sh STRING that prints the first half of STRING on one line and the rest on the next line. The first half has \${#s}/2 characters (integer division), so for an odd length the second line is one character longer. Example: ./halves.sh abcdef prints abc then def; ./halves.sh abcde prints ab then cde."
file halves.sh
run './halves.sh abcdef'
run './halves.sh abcde'
run './halves.sh "hello world!"'
run './halves.sh "  two spaces  "'
run './halves.sh'

task 16 script home/user1 "Write info.sh that prints four lines: script: NAME (the script's name without any directory, from \$0), count: N (number of arguments), first: ARG1, second: ARG2. A missing argument prints as nothing after the colon and space. Example: ./info.sh x y z prints script: info.sh / count: 3 / first: x / second: y."
file info.sh
run './info.sh x y z'
run './info.sh'
run './info.sh "a b" "c  d"'
run 'mkdir bin; cp info.sh bin; ./bin/info.sh one; rm -r bin'

task 17 script home/user1 "Write calc.sh A B. If it does not get exactly 2 arguments it prints Usage: calc.sh a b to standard error and exits with status 1. Otherwise it prints five lines in this exact form (for 17 and 5): 17 + 5 = 22, 17 - 5 = 12, 17 * 5 = 85, 17 / 5 = 3, 17 % 5 = 2 (integer arithmetic) and exits with status 0."
file calc.sh
run './calc.sh 17 5; echo "exit=$?"'
run './calc.sh -7 2; echo "exit=$?"'
run './calc.sh; echo "exit=$?"'
run './calc.sh 1 2 3; echo "exit=$?"'

task 18 script home/user1 "Write backup.sh FILE (from the variables notebook) that copies FILE to a new file whose name is FILE followed by _.bak (so abc is copied to abc_.bak). Careful: \$in_.bak is not what you want. Names may contain spaces."
file backup.sh
run './backup.sh report.txt; ls'
run './backup.sh "my notes.txt"; ls; cat "my notes.txt_.bak"'

task 19 script home/user1 "Write hello2.sh that prints Hello, NAME! where NAME is the first argument, or the word world if the first argument is missing or is the empty string. Use the \${parameter:-word} expansion."
file hello2.sh
run './hello2.sh Sam'
run './hello2.sh'
run './hello2.sh ""'
run './hello2.sh "Mary Ann" extra'

task 20 script home/user1 "Write iseven.sh N (arithmetic notebook): it prints nothing and exits with status 0 if N is even and 1 if N is odd. With no argument it exits with status 0."
file iseven.sh
run './iseven.sh 4; echo $?'
run './iseven.sh 7; echo $?'
run './iseven.sh 0; echo $?'
run './iseven.sh; echo $?'
run './iseven.sh -3; echo $?'
