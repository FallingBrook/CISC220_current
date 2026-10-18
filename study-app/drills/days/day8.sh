# Day 8: type in your handwritten answers to Mock midterm B and grade them.
# Each task is one question part from Mock B (the part id is in the prompt).
DAY_TITLE="Mock B: type in and test your answers"

setup_sandbox() {
    mkdir -p home/user1
    cd home/user1 || return
    printf '%s\n' CISC220 CISC1240 cisc220 MATH110 CHEM112A PSYC100 'CISC 220' ABC123 STAT263 > codes.txt
    printf 'notes\n' > notes.txt
    mkdir docs
}

task B1b cmd home/user1 "Mock B 1B. Test your regex: write  grep -E 'YOUR_REGEX' codes.txt  so that it prints exactly the lines of codes.txt that are four uppercase letters followed by exactly three digits (nothing else on the line)."
ref "grep -E '^[A-Z]{4}[0-9]{3}$' codes.txt"
compare out

task B1c cmd home/user1 "Mock B 1C. Create an array named fruits holding the three values: red apple, green pear, plum. End your line with:   ; printf '[%s]\n' \"\${fruits[@]}\""
ref "fruits=(\"red apple\" \"green pear\" \"plum\"); printf '[%s]\n' \"\${fruits[@]}\""
compare out

task B1d cmd home/user1 "Mock B 1D. Start your line with   fruits=(\"red apple\" \"green pear\");   then append the value kiwi to the end of fruits, and end with   ; printf '[%s]\n' \"\${fruits[@]}\""
ref "fruits=(\"red apple\" \"green pear\"); fruits+=(\"kiwi\"); printf '[%s]\n' \"\${fruits[@]}\""
compare out

task B1f script home/user1 "Mock B 1F. Write q1f.sh: line 1 after the shebang is f=\$1, then your one-line if statement that prints missing to standard error if the file named by f does not exist (prints nothing otherwise)."
file q1f.sh
run './q1f.sh nosuch.txt'
run './q1f.sh notes.txt'
run './q1f.sh docs'
run './q1f.sh "no such file"'

task B1g text . "Mock B 1G. What is the exit status of the command  (( 5 - 5 ))  ?"
accept '1'

task B1h cmd home/user1 "Mock B 1H. Write a C-style for loop (on one line) that prints the even numbers 0, 2, 4, ..., 10, one per line."
ref 'for (( i = 0; i <= 10; i += 2 )); do echo "$i"; done'
compare out

task B1k script home/user1 "Mock B 1K. Write q1k.sh: s=\$1 then one line that uses tr to print the value of s with every digit deleted."
file q1k.sh
run 'out=$(./q1k.sh "CISC220 room 101"); echo "[$out]"'
run 'out=$(./q1k.sh "no digits"); echo "[$out]"'
run 'out=$(./q1k.sh "2026-10-27"); echo "[$out]"'

task B1l text . "Mock B 1L. What does this print?   s=banana.tar.gz; echo \"\${s%%.*} \${s#*.}\""
accept 'banana tar.gz'

task B2a script home/user1 "Mock B 2A. Write isnum.sh: s=\$1 then an if statement: if s is made up only of digits (at least one) print  S is a number  (S is the value of s) to standard output, otherwise print  S is not a number  to standard error."
file isnum.sh
run './isnum.sh 220'
run './isnum.sh 0'
run './isnum.sh -5'
run './isnum.sh 12a'
run './isnum.sh ""'
run './isnum.sh "1 2"'

task B2b script home/user1 "Mock B 2B. Write sum.sh: use a for loop over the command line arguments to compute their sum (assume they are integers) and print it. With no arguments it prints 0."
file sum.sh
run './sum.sh 1 2 3 4'
run './sum.sh'
run './sum.sh 10 -3 100'

task B3 script home/user1 "Mock B Question 3. Write countchar.sh containing only the function count_char (no shebang needed; the tests source it). count_char CH STR prints how many times the character CH appears in the string STR and returns 0 if CH appears at least once, 1 otherwise. It must not change any variable of the caller (use local)."
file countchar.sh
run '. ./countchar.sh; count_char a banana; echo "status=$?"'
run '. ./countchar.sh; count_char z banana; echo "status=$?"'
run '. ./countchar.sh; count_char " " "a b  c"; echo "status=$?"'
run '. ./countchar.sh; count_char "*" "a*b*"; echo "status=$?"'
run '. ./countchar.sh; count_char x ""; echo "status=$?"'
run '. ./countchar.sh; i=7; count_char s mississippi; echo "i=$i"'

task B4 script home/user1 "Mock B Question 4 (uniqrev.sh). Prints the command line arguments on one line, in reverse order, with repeated values removed (keep the first occurrence in the original order). Example: ./uniqrev.sh 3 1 3 2 1 prints 2 1 3. Arguments may contain spaces or wildcard characters. With no arguments print  Usage: uniqrev.sh value...  to standard error and exit 1. Use the functions contains, dedup and reverse described in the mock."
file uniqrev.sh
run './uniqrev.sh 3 1 3 2 1; echo "exit=$?"'
run './uniqrev.sh; echo "exit=$?"'
run './uniqrev.sh one; echo "exit=$?"'
run './uniqrev.sh a b c d'
run './uniqrev.sh "a b" c "a b" a'
run './uniqrev.sh ab "a*"'
run './uniqrev.sh 5 5 5 5'
