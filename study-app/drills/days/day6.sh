# Day 6: arrays, loops, and functions
DAY_TITLE="Arrays, loops, and functions"

setup_sandbox() {
    mkdir -p home/user1/ext home/user1/marking/stu1 home/user1/marking/stu2 "home/user1/marking/stu 3"
    cd home/user1 || return
    printf '# student number, last name, first name\n12345,Parr,Jack-Jack\n23456,Wazowski,Mike\n98765,Best,Lucius\n' > students.txt
    printf '# number,last,first\n11111,Case,Justin\n22222,Deere,Pierce\n' > "class list.txt"
    cd ext || return
    echo "alpha" > a.txt
    echo "bravo" > b.txt
    echo "my notes" > "my notes.txt"
    echo "# heading" > c.md
    echo "backup" > d.txt.bak
    echo "plain" > notes
    cd ../marking || return
    echo 'echo stu1' > stu1/A1.sh
    echo 'readme 1' > stu1/README
    echo 'echo stu2' > stu2/A1.sh
    echo 'readme 3' > "stu 3/README"
    mkdir "stu 3/A1.sh"
    echo "marking notes" > notes.txt
}

task 1 cmd home/user1/ext "Write a one-line for loop that prints the name of every file in the current directory whose name ends in .txt, one name per line. (Quote the variable.)"
ref 'for f in *.txt; do echo "$f"; done'
compare out

task 2 cmd home/user1/ext "Write a one-line for loop that prints the name of every .txt file in the current directory WITHOUT its .txt extension, one per line (my notes.txt prints as: my notes)."
ref 'for f in *.txt; do echo "${f%.txt}"; done'
compare out

task 3 cmd home/user1/marking "Write a one-line for loop over the subdirectories of the current directory (use the glob */) that prints each subdirectory name, one per line, exactly as the glob produces it (with its trailing /)."
ref 'for d in */; do echo "$d"; done'
compare out

task 4 cmd home/user1 "Use mapfile to read the lines of students.txt into an array named lines (remove the newlines), then print the number of elements in the array. Write both commands on one line separated by ;"
ref 'mapfile -t lines < students.txt; echo "${#lines[@]}"'
compare out

task 5 cmd home/user1 "Use a while read loop to read students.txt one line at a time, splitting each line at commas into three variables, and print only the last name (the second field) of each student. Skip the line that starts with #. One line, e.g. while IFS=, read -r ...; do ...; done < students.txt"
ref 'while IFS=, read -r num last first; do [[ $num =~ ^# ]] && continue; echo "$last"; done < students.txt'
compare out

task 6 cmd . "Start your line with s=banana; then use a C-style for loop and \${s:i:1} to print each character of s on its own line."
ref 's=banana; for (( i = 0; i < ${#s}; i++ )); do echo "${s:i:1}"; done'
compare out

task 7 cmd . "Start your line with arr=([2]=x [5]=y [9]=z); then print, on one line, the list of indexes that arr uses (use an array expansion, not echo 2 5 9)."
ref 'arr=([2]=x [5]=y [9]=z); echo "${!arr[@]}"'
compare out

task 8 text . "Fill in the blank so the loop processes each command line argument of a script, keeping arguments that contain spaces whole:   for arg in ____; do"
accept '"$@"'

task 9 text . "Write the expansion that gives the number of elements in the array arr."
accept '${#arr[@]}'
accept '${#arr[*]}'
accept '"${#arr[@]}"'

task 10 text . "Write the expansion that gives the list of indexes used by the array arr."
accept '${!arr[@]}'
accept '${!arr[*]}'
accept '"${!arr[@]}"'

task 11 text . "Which builtin command, used inside a function, creates a variable that does not overwrite a variable of the same name in the main script?"
accept 'local'

task 12 text . "A function ends by running: return 258   What is the value of \$? right after the function call? (Exit statuses keep only the low 8 bits.)"
accept '2'

task 13 script home/user1/ext "Write chext.sh. With one argument EXT it renames every file in the current directory whose name ends in .EXT so the .EXT is removed (a.txt becomes a). With two arguments SRC DST it changes the extension .SRC to .DST (a.txt becomes a.md). Use a for loop and mv. If no file has the extension, do nothing, print nothing, and exit with status 0. Filenames may contain spaces."
file chext.sh
run './chext.sh txt; ls'
run './chext.sh txt md; ls'
run './chext.sh md text; ls'
run './chext.sh pdf; echo "exit=$?"; ls'

task 14 script home/user1/marking "Write checksubs.sh FILE... For each immediate subdirectory of the current directory (loop over */), if any FILE given on the command line is missing from it or is not a regular file, print the subdirectory name with its trailing / (exactly as */ produces it, e.g. stu 3/) to standard error, once. Exit with status 1 if any subdirectory was printed, otherwise 0. With no arguments, print nothing and exit 0."
file checksubs.sh
run './checksubs.sh A1.sh README; echo "exit=$?"'
run './checksubs.sh A1.sh; echo "exit=$?"'
run './checksubs.sh README 2>&1; echo "exit=$?"'
run './checksubs.sh; echo "exit=$?"'

task 15 script home/user1 "Write funcs.sh, a file of functions (no shebang needed) that will be sourced. hasdups STR: find the first index i whose character appears again later, at first such index j>i; print c:i = c:j (e.g. hasdups abca prints a:0 = a:3) and return 0; if no character repeats print nothing and return 1. indexof CH STR: print the index of the first CH in STR and return 0; if absent print -1 and return 1. Compare characters exactly (a * in STR is just a character)."
file funcs.sh
run 'source ./funcs.sh; hasdups abca; echo $?'
run 'source ./funcs.sh; hasdups "1 2 3"; echo $?'
run 'source ./funcs.sh; hasdups abc; echo $?'
run 'source ./funcs.sh; hasdups "a*b*"; echo $?'
run 'source ./funcs.sh; indexof c abcabc; echo $?'
run 'source ./funcs.sh; indexof z abc; echo $?'
run 'source ./funcs.sh; indexof "*" "ab*"; echo $?'

task 16 script home/user1 "Write rev.sh that stores its command line arguments in an array and prints them in reverse order, one per line. An argument containing spaces must print as one line. With no arguments it prints nothing (exit status 0)."
file rev.sh
run './rev.sh a "b c" d'
run './rev.sh one'
run './rev.sh; echo "exit=$?"'

task 17 script home/user1 "Write largest.sh INT... It must define a function max that prints the largest of its arguments, call it with all the script's arguments, capture the result with command substitution, and print: largest: N  With no arguments print Usage: largest.sh int... to standard error and exit with status 1."
file largest.sh
run './largest.sh 3 9 -2 7'
run './largest.sh -5 -1 -9'
run './largest.sh 42'
run './largest.sh; echo "exit=$?"'

task 18 script home/user1 "Write sortargs.sh INT... that puts its arguments in an array arr, sorts arr in ascending order with selection sort (functions sort and minidx, like Quiz 2 Q4), and prints the sorted values on one line separated by single spaces. With no arguments it prints an empty line."
file sortargs.sh
run './sortargs.sh 0 3 1 4 2'
run './sortargs.sh 5 -1 5 0 12'
run './sortargs.sh 7'
run './sortargs.sh; echo "exit=$?"'

task 19 script home/user1/ext "Write extcount.sh EXT... For each argument EXT (in order) print a line EXT: N where N is the number of names in the current directory ending in .EXT (print 0 when nothing matches). No arguments: print nothing."
file extcount.sh
run './extcount.sh txt md pdf'
run './extcount.sh bak'
run './extcount.sh; echo "exit=$?"'

task 20 script home/user1 "Write names.sh FILE. FILE has lines of the form number,last,first. Read it line by line with while read and print each student as: first last (number)  for example Mike Wazowski (23456). Skip lines that start with #. The filename may contain spaces."
file names.sh
run './names.sh students.txt'
run './names.sh "class list.txt"'
