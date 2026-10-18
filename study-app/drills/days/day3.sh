# Day 3: streams, redirection, pipelines, tee, expansions, and tr.
DAY_TITLE="Streams, pipelines, expansions, and tr"

setup_sandbox() {
    mkdir -p home/user1
    cd home/user1 || return
    printf 'Cade\tBarry\t3100025\nDay\tHolly\t2999999\nFriese\tAndy\t3001111\nYu\tSue\t1990000\nLee\tAndy\t3050001\nMoss\tKim\t2500500\nNash\tSue\t2750075\n' > classlist
    printf 'Ahn\tMia\t3200001\nZhou\tLi\t2100002\nBell\tAva\t2900003\n' > 'class list 2'
    printf 'alice\t72\nbob\t95\ncarol\t88\ndave\t61\nerin\t100\nfrank\t9\n' > grades
    printf '42\n7\n100\n15\n3\n88\n21\n' > nums.txt
    printf 'pear\napple\nfig\napple\nkiwi\npear\napple\nbanana\n' > words.txt
    printf 'too    many     spaces   here\nand   here    too\n' > messy.txt
    printf 'room 101, floor 3, building 42\n' > code.txt
    echo "my original notes" > notes.txt
    echo "started" > log.txt
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

task 12 cmd home/user1 "messy.txt contains runs of several spaces. Use tr to print its contents with every run of spaces squeezed down to a single space."
ref "tr -s ' ' < messy.txt"
compare out

task 13 cmd home/user1 "Use tr to print the contents of code.txt with all digits deleted."
ref 'tr -d 0-9 < code.txt'
compare out

task 14 cmd home/user1 "Use tr to create a file named classlist.csv that is a copy of classlist with every TAB replaced by a comma."
ref "tr '\t' ',' < classlist > classlist.csv"

task 15 cmd home/user1 "Using ONE mkdir command with a brace expansion, create the 12 directories week01, week02, ..., week12 (two-digit numbers)."
ref 'mkdir week{01..12}'

task 16 cmd home/user1 "Using echo and a command substitution, print the sentence: classlist has N lines   where N is computed by wc (N must be just the number)."
ref 'echo "classlist has $(wc -l < classlist) lines"'
compare out

task 17 text . "Which file descriptor number refers to standard error?"
accept '2'

task 18 script home/user1 "Write a script snums.sh. Its first command line argument (\$1) is the name of a classlist-style file (TAB-separated: last name, first name, student number). The script prints the student numbers from that file in ascending sorted order, one per line. The file name may contain spaces."
file snums.sh
run './snums.sh classlist'
run './snums.sh "class list 2"'

task 19 script home/user1 "Write a script top3.sh that takes two arguments: \$1 is a file with lines of the form name TAB mark, and \$2 is an output file name. The script saves ALL the marks, sorted numerically from highest to lowest, into the file \$2, and prints only the three highest marks. Use one pipeline with tee."
file top3.sh
run './top3.sh grades best; echo ---; cat best'
run './top3.sh grades "my marks"; cat "my marks" | wc -l'

task 20 script home/user1 "Write a script upper.sh that prints its first argument converted to UPPERCASE letters using tr (other characters unchanged, spacing preserved exactly). Example: ./upper.sh 'cisc  220' prints CISC  220"
file upper.sh
run './upper.sh hello'
run "./upper.sh 'cisc  220   rocks'"
run "./upper.sh '*'"
