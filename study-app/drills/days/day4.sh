# Day 4: variables, strings, tr, and regular expressions
DAY_TITLE="Variables, strings, tr, and regular expressions"

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
    printf 'too    many     spaces   here\nand   here    too\n' > messy.txt
    printf 'room 101, floor 3, building 42\n' > code.txt
    printf '%s\n' apple Banana cherry date fig kiwi x-ray a Apple2 2cool \
        color colour colouur colr sing singing zebra mississippi r2d2 yes \
        'hello world' > words.txt
    printf '%s\n' 'INFO server started' 'WARN disk 85% full' 'ERROR cannot open config.txt' \
        'INFO user1 logged in' 'error: this line is lowercase' 'WARN memory low' \
        'ERROR disk full' 'INFO done' > log.txt
    chmod 640 a.txt
    chmod 644 b.txt "copy target.txt"
    chmod 600 "my notes.txt"
    chmod 755 somedir
}

# ---------------------------------------------------------------- variables
task 1 cmd home/user1 "Give b.txt exactly the same permissions as a.txt. Get the permissions of a.txt with stat -c %a a.txt inside a command substitution \$( ). You may do it in one chmod command, or first store the value in a variable named perm and then run chmod, with the two commands on one line separated by a semicolon."
ref 'chmod "$(stat -c %a a.txt)" b.txt'

task 2 script home/user1 "Write backup.sh FILE (from the variables notebook). It copies FILE to a new file whose name is FILE followed by _.bak, so abc is copied to abc_.bak. It prints nothing. Careful: \$in_.bak is not what you want. File names may contain spaces, so quote your variables. The script is run from home/user1."
file backup.sh
run './backup.sh report.txt; ls'
run './backup.sh "my notes.txt"; ls; cat "my notes.txt_.bak"'

task 3 script home/user1 "Write copyperm.sh SRC DEST (Quiz 1, Q4). It sets the permissions of file DEST to be equal to the permissions of file SRC, using stat -c %a and chmod. It prints nothing. File names can contain spaces, so quote your variables. The script is run from home/user1."
file copyperm.sh
run './copyperm.sh a.txt b.txt; stat -c %a b.txt'
run './copyperm.sh "my notes.txt" "copy target.txt"; stat -c %a "copy target.txt"'
run './copyperm.sh somedir b.txt; stat -c %a b.txt'

# ---------------------------------------------------------------- strings
task 4 cmd home/user1 "On one line: store the pathname /home/user1/courses/CISC220/notes.txt in a variable p, then print only its directory part (/home/user1/courses/CISC220) using a parameter expansion that removes the shortest trailing part matching /*. Separate the two commands with a semicolon."
ref 'p=/home/user1/courses/CISC220/notes.txt; echo "${p%/*}"'
compare out

task 5 cmd home/user1 "On one line: store the filename lab 1.txt (it contains a space) in a variable f, then rename that file so every space in its name becomes an underscore (new name lab_1.txt). Use mv and the replace-all expansion \${f//pattern/replacement}."
ref 'f="lab 1.txt"; mv "$f" "${f// /_}"'

task 6 cmd home/user1 "On one line: store the contents of word.txt in a variable s (use command substitution with cat), then print the first half of s using \${s:offset:length} and \${#s}. word.txt holds an 8-character word, so 4 characters are printed. (Arithmetic expansion \$(( )) from Day 3 may help.)"
ref 's=$(cat word.txt); echo "${s:0:${#s}/2}"'
compare out

task 7 script home/user1 "Write trash.sh PATHNAME (Quiz 1, Q5). PATHNAME always contains a /. The script (1) finds the directory dir that the file is in, (2) creates the directory dir/.trash, (3) sets the permissions of .trash to rwx for the owner and nothing for anyone else, (4) prints: moving PATHNAME to the trashcan (5) moves the file into .trash. No error checking is needed. The script is run from home/user1."
file trash.sh
run './trash.sh ./myfile; ls -A; ls -A .trash; stat -c %a .trash'
run './trash.sh "somedir/my file"; ls -A somedir somedir/.trash'
run './trash.sh "$SB/home/user1/somedir/myfile"; ls -A somedir/.trash'

task 8 script home/user1 "Write newext.sh FILE EXT that renames FILE so that its last extension is replaced by EXT. Example: ./newext.sh report.txt md renames report.txt to report.md; ./newext.sh archive.tar.gz zip renames it to archive.tar.zip. Use mv and \${f%.*}. Print nothing. Names may contain spaces. The script is run from home/user1."
file newext.sh
run './newext.sh report.txt md; ls'
run './newext.sh archive.tar.gz zip; ls'
run './newext.sh "lab 1.txt" text; ls'

task 9 script home/user1 "Write halves.sh STRING that prints the first half of STRING on one line and the rest on the next line. The first half has \${#s}/2 characters (integer division with \$(( ))), so for an odd length the second line is one character longer. Example: ./halves.sh abcdef prints abc then def; ./halves.sh abcde prints ab then cde. With no argument it prints two empty lines."
file halves.sh
run './halves.sh abcdef'
run './halves.sh abcde'
run './halves.sh "hello world!"'
run './halves.sh "  two spaces  "'
run './halves.sh'

task 10 script home/user1 "Write hello2.sh that prints Hello, NAME! where NAME is the first argument, or the word world if the first argument is missing or is the empty string. Use the \${parameter:-word} expansion. Examples: ./hello2.sh Sam prints Hello, Sam! and ./hello2.sh prints Hello, world!"
file hello2.sh
run './hello2.sh Sam'
run './hello2.sh'
run './hello2.sh ""'
run './hello2.sh "Mary Ann" extra'

# ---------------------------------------------------------------- tr
task 11 cmd home/user1 "messy.txt contains runs of several spaces. Use tr to print its contents with every run of spaces squeezed down to a single space. (Remember: tr reads only standard input.)"
ref "tr -s ' ' < messy.txt"
compare out

task 12 cmd home/user1 "Use tr to print the contents of code.txt with all digits deleted."
ref 'tr -d 0-9 < code.txt'
compare out

task 13 cmd home/user1 "Use tr to create a file named classlist.csv that is a copy of classlist with every TAB replaced by a comma. (In tr, a TAB is written '\\t'.)"
ref "tr '\t' ',' < classlist > classlist.csv"

task 14 script home/user1 "Write upper.sh that prints its first argument converted to UPPERCASE letters using tr (other characters unchanged, spacing preserved exactly). Example: ./upper.sh 'cisc  220' prints CISC  220"
file upper.sh
run './upper.sh hello'
run "./upper.sh 'cisc  220   rocks'"
run "./upper.sh '*'"

# ---------------------------------------------------------------- regular expressions
task 15 cmd home/user1 "words.txt has one word per line. Using grep -E and ONE regular expression with the ? metacharacter, print the lines of words.txt that are exactly color or exactly colour (nothing else on the line)."
ref 'grep -E "^colou?r$" words.txt'
compare out

task 16 cmd home/user1 "Print the lines of log.txt that contain ERROR (uppercase), each preceded by its line number."
ref 'grep -En ERROR log.txt'
compare out

task 17 cmd home/user1 "Using ONE regular expression with the choice operator |, print the lines of log.txt that start with ERROR or start with WARN."
ref 'grep -E "^(ERROR|WARN)" log.txt'
compare out

task 18 cmd home/user1 "Print the lines of words.txt that start with a lowercase letter AND end with a lowercase letter. Anything may be in between, and a one-letter line such as a counts too (Quiz 2 Q1B)."
ref 'grep -E "^[a-z](.*[a-z])?$" words.txt'
compare out

task 19 text . "What does this print? (two commands on one line)   re='a.c'; [[ abc =~ \"\$re\" ]]; echo \$?"
accept '1'

task 20 script home/user1 "Write isint.sh VALUE. If VALUE is a signed or unsigned integer (an optional + or -, then one or more digits, and nothing else) it prints: VALUE is an integer   Otherwise it prints: VALUE is not an integer   (both to standard output). Use [[ \$1 =~ regex ]] with && and || (no if: that is Day 5). Only the output is checked, not the exit status. Example: ./isint.sh -7 prints -7 is an integer"
file isint.sh
compare out,err,fs
run './isint.sh 42'
run './isint.sh -7'
run './isint.sh +13'
run './isint.sh 4x2'
run './isint.sh "1 2"'
run './isint.sh -'
run './isint.sh 12a'
