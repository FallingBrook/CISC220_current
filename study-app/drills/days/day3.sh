# Day 3: streams, redirection, pipelines, tee, expansions, and your first scripts.
DAY_TITLE="Streams, pipelines, expansions, and your first scripts"

setup_sandbox() {
    mkdir -p home/user1
    cd home/user1 || return
    printf 'Cade\tBarry\t3100025\nDay\tHolly\t2999999\nFriese\tAndy\t3001111\nYu\tSue\t1990000\nLee\tAndy\t3050001\nMoss\tKim\t2500500\nNash\tSue\t2750075\n' > classlist
    printf 'Ahn\tMia\t3200001\nZhou\tLi\t2100002\nBell\tAva\t2900003\n' > 'class list 2'
    printf 'alice\t72\nbob\t95\ncarol\t88\ndave\t61\nerin\t100\nfrank\t9\n' > grades
    printf '42\n7\n100\n15\n3\n88\n21\n' > nums.txt
    printf 'pear\napple\nfig\napple\nkiwi\npear\napple\nbanana\n' > words.txt
    echo "my original notes" > notes.txt
    echo "started" > log.txt
    printf '#!/bin/bash\n\n# hello.sh\n\necho "Hello from a script!"\n' > hello.sh
    chmod 644 hello.sh
}

task 1 cmd home/user1 "classlist has one student per line: last name, first name, student number, separated by TAB characters. Print only the student numbers (the third field), in file order."
ref 'cut -f3 classlist'
compare out

task 2 cmd home/user1 "Write ONE pipeline that extracts the student numbers from classlist, sorts them in ascending order, saves all of the sorted numbers to a file named snum, and prints only the first three sorted numbers. (Hint: tee.)"
ref 'cut -f3 classlist | sort | tee snum | head -n3'

task 3 cmd home/user1 "Overwrite the contents of notes.txt with the single line OOPS, using echo and a redirection."
ref 'echo OOPS > notes.txt'

task 4 cmd home/user1 "Add the line DONE to the end of log.txt, keeping the line that is already there."
ref 'echo DONE >> log.txt'

task 5 cmd home/user1 "Run: ls classlist nosuchfile   but send its standard error (the error message) to a new file named err.txt. Normal output should still appear on the terminal."
ref 'ls classlist nosuchfile 2> err.txt'

task 6 cmd home/user1 "Run: ls classlist nosuchfile   so that BOTH its normal output and its error message go into a file named all.txt (nothing appears on the terminal)."
ref 'ls classlist nosuchfile > all.txt 2>&1'
compare out,err,fs

task 7 cmd home/user1 "Run: ls classlist nosuchfile   throwing away the error message (send it to the null device) while normal output still appears on the terminal."
ref 'ls classlist nosuchfile 2> /dev/null'
compare out,err,fs

task 8 cmd home/user1 "Print ONLY the number of lines in classlist (just the number, no file name). Hint: give wc its input through standard input."
ref 'wc -l < classlist'
compare out

task 9 cmd home/user1 "nums.txt has one integer per line. Print the numbers sorted numerically from largest to smallest."
ref 'sort -n -r nums.txt'
compare out

task 10 cmd home/user1 "words.txt has one word per line, with repeats. Print each different word exactly once, in sorted order."
ref 'sort words.txt | uniq'
compare out

task 11 cmd home/user1 "Print only the words in words.txt that appear more than once (each such word printed once, in sorted order)."
ref 'sort words.txt | uniq -d'
compare out

task 12 cmd home/user1 "Using ONE mkdir command with a brace expansion, create the 12 directories week01, week02, ..., week12 (two-digit numbers)."
ref 'mkdir week{01..12}'

task 13 cmd home/user1 "Using echo and a command substitution, print the sentence: classlist has N lines   where N is computed by wc (N must be just the number)."
ref 'echo "classlist has $(wc -l < classlist) lines"'
compare out

task 14 text . "Which file descriptor number refers to standard error?"
accept '2'

task 15 cmd home/user1 "The sandbox has a script hello.sh with permissions rw-r--r-- (not executable). On ONE line, give the owner (only the owner) execute permission on hello.sh, and then run it with ./ (join the two commands with && or ;)."
ref 'chmod u+x hello.sh && ./hello.sh'

task 16 text . "Inside a script, which special parameter holds the number of command line arguments? Write it the way you would use it, with the dollar sign (Quiz 1 Q2E: echo ...)."
accept '$#'
accept '${#}'
accept '"$#"'
accept 'echo $#'
accept 'echo "$#"'
accept 'echo ${#}'

task 17 script home/user1 "Write your first drill script, greet.sh. It prints: Hello, NAME! where NAME is the first command line argument (\$1). Example: ./greet.sh Sam prints Hello, Sam!   Start the file with #!/bin/bash. The checker copies it into sandbox/home/user1, makes it executable, and runs commands like ./greet.sh Sam there."
file greet.sh
run './greet.sh Sam'
run './greet.sh "Mary Ann"'
run './greet.sh'

task 18 script home/user1 "Write info.sh that prints exactly three lines: script: P   (P is the pathname used to run the script, \$0), then count: N   (N is the number of arguments), then first: A   (A is the first argument; if there is none, nothing follows the colon and space). Example: ./info.sh x y z prints script: ./info.sh / count: 3 / first: x (on three lines). Quote your parameters as the course requires, e.g. echo \"first: \$1\", so an argument with two spaces inside keeps them. The checker runs it from sandbox/home/user1."
file info.sh
run './info.sh x y z'
run './info.sh'
run './info.sh "a  b" "c d"'
run 'mkdir bin; cp info.sh bin; ./bin/info.sh one; rm -r bin'

task 19 script home/user1 "Write a script snums.sh. Its first command line argument (\$1) is the name of a classlist-style file (TAB-separated: last name, first name, student number). The script prints the student numbers from that file in ascending sorted order, one per line. The file name may contain spaces, so quote \$1. The checker runs it from sandbox/home/user1, where classlist and 'class list 2' are."
file snums.sh
run './snums.sh classlist'
run './snums.sh "class list 2"'

task 20 script home/user1 "Write a script top3.sh that takes two arguments: \$1 is a file with lines of the form name TAB mark, and \$2 is an output file name. The script saves ALL the marks, sorted numerically from highest to lowest, into the file \$2, and prints only the three highest marks. Use one pipeline with tee. The checker runs it from sandbox/home/user1, where the file grades is."
file top3.sh
run './top3.sh grades best; echo ---; cat best'
run './top3.sh grades "my marks"; cat "my marks" | wc -l'
