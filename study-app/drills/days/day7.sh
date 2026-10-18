# Day 7: type in your handwritten answers to Mock midterm A and grade them.
# Each task is one question part from Mock A (the part id is in the prompt).
# Parts that cannot be auto-graded (explanations) are marked in the app with the model answer.
DAY_TITLE="Mock A: type in and test your answers"

setup_sandbox() {
    mkdir -p home/user1/notes home/user1/photos/trip home/user1/scripts
    cd home/user1 || return
    printf 'Lecture 1: the filesystem\n' > notes/lec01.txt
    printf 'Lecture 2: commands\n' > notes/lec02.txt
    printf 'unfinished thoughts\n' > notes/.draft
    printf -- '- study for the midterm\n' > notes/todo.md
    printf 'JPG1' > photos/img1.jpg
    printf 'JPG2' > photos/img2.JPG
    printf 'PNG' > photos/logo.png
    printf 'TRIP' > photos/trip/beach.jpg
    printf '#!/bin/bash\necho backup\n' > scripts/backup.sh
    printf '#!/bin/bash\necho run\n' > scripts/run.sh
    printf '#!/bin/bash\necho tidy\n' > scripts/tidy.sh
    chmod 664 scripts/backup.sh
    chmod 640 scripts/run.sh
    chmod 622 scripts/tidy.sh
    printf '%s\n' '3100025,Cade,78' '2999999,day,85' '3001111,Friese,91' '1990000,yu,66' \
        '3200001,Abara,88' '3150002,MacLeod,73' '3050003,singh,95' > grades.csv
    # files used by the stash.sh tests
    mkdir -p work/sub
    printf 'a' > work/report.txt
    printf 'bb' > work/data.tar.gz
    printf 'ccc' > work/Makefile
    printf 'dddd' > "work/my notes.txt"
    printf 'eeeee' > work/sub/plan.txt
}

task A1a text . "Mock A 1A. What is the absolute pathname of the file backup.sh? (Write it as it would appear on the exam, starting with /)"
accept '/home/user1/scripts/backup.sh'

task A1b text . "Mock A 1B. The current working directory is photos. What is the relative pathname of the file lec02.txt?"
accept '../notes/lec02.txt'

task A1c text . "Mock A 1C. The current working directory is trip. What single command changes the current working directory to notes using a relative pathname?"
accept 'cd ../../notes'
accept 'cd ../../notes/'

task A1d cmd home/user1 "Mock A 1D. The current working directory is user1. Copy all of the files in notes whose names end in .txt into the scripts directory (single command)."
ref 'cp notes/*.txt scripts'

task A1e cmd home/user1/photos "Mock A 1E. The current working directory is photos. List all files whose names end in .jpg where any of the letters j, p, g may be uppercase or lowercase (single command)."
ref 'ls *.[jJ][pP][gG]'
compare out

task A1f cmd home/user1 "Mock A 1F. The current working directory is user1. Remove the directory photos and everything inside it (single command)."
ref 'rm -r photos'

task A2b cmd home/user1/scripts "Mock A 2B. The current working directory is scripts. Using an octal value, set the permissions of backup.sh to rwxr-x--x."
ref 'chmod 751 backup.sh'

task A2c cmd home/user1/scripts "Mock A 2C. The current working directory is scripts. Using symbolic permissions in a single chmod command, remove write permission for the group and others and add execute permission for the owner on every file whose name ends in .sh. All other permissions must stay as they are."
ref 'chmod u+x,go-w *.sh'

task A2d cmd home/user1 "Mock A 2D. The current working directory is user1. Run ls notes missing so that its normal output goes to the file out.txt and its error messages go to the file err.txt (single command)."
ref 'ls notes missing > out.txt 2> err.txt'
compare out,err,fs

task A2e text . "Mock A 2E. What exactly does this command print?   echo '\$HOME is \"home\"'"
accept '$HOME is "home"'

task A2f cmd home/user1 "Mock A 2F. The current working directory is user1. Using a brace expansion, create the 12 directories week01, week02, ..., week12 with one short command."
ref 'mkdir week{01..12}'

task A3a script . "Mock A 3A. Write parts.sh: it stores its first command line argument in a variable named path (path=\$1) and then, using parameter expansions only (no other commands except echo), prints the last part of the pathname (the filename) on one line and the directory part on the next line. Example: ./parts.sh /home/user1/notes/lec01.txt prints lec01.txt then /home/user1/notes. You may assume the pathname contains at least one /."
file parts.sh
run './parts.sh /home/user1/notes/lec01.txt'
run './parts.sh notes/lec01.txt'
run './parts.sh ./archive.tar.gz'
run './parts.sh "/home/user1/my notes/a b.txt"'

task A3b cmd home/user1 "Mock A 3B. The current working directory is user1. grades.csv has lines of the form studentnumber,lastname,grade (comma separated). Write one pipeline that extracts the last names, converts them to uppercase with tr, sorts them alphabetically, saves the sorted names in names.txt, and prints the first 5 sorted names."
ref "cut -d, -f2 grades.csv | tr 'a-z' 'A-Z' | sort | tee names.txt | head -n 5"

task A4 script home/user1/scripts "Mock A Question 4. Write mkscript.sh NAME. If the number of arguments is not exactly 1, print  Usage: mkscript.sh name  to standard error and exit with status 1. If a file named NAME.sh already exists, print  mkscript.sh: NAME.sh already exists  to standard error and exit with status 2. Otherwise create NAME.sh containing the single line #!/bin/bash and set its permissions so the owner can read, write and execute it and nobody else has any permission."
file mkscript.sh
run './mkscript.sh; echo "exit=$?"'
run './mkscript.sh a b; echo "exit=$?"'
run './mkscript.sh hello; echo "exit=$?"; cat hello.sh; ls -l hello.sh | cut -c1-10'
run './mkscript.sh run; echo "exit=$?"; cat run.sh'
run './mkscript.sh "my tool"; echo "exit=$?"; ls'

task A5 script home/user1 "Mock A Question 5 (stash.sh). For each command line argument (a pathname): if it is not a regular file print  stash.sh: PATH is not a regular file  to standard error and go on to the next argument. Otherwise let DIR be the directory part of the pathname (or . if the pathname has no /) and EXT the part of the filename after its last . (or other if the filename has no .); create DIR/.stash/EXT (no error if it exists), set the permissions of DIR/.stash to rwx------, print  stashing PATH in DIR/.stash/EXT  and move the file into DIR/.stash/EXT. With no arguments print  Usage: stash.sh file...  to standard error and exit 1. Exit with status 2 if any argument was not a regular file, otherwise 0."
file stash.sh
run './stash.sh; echo "exit=$?"'
run './stash.sh work/report.txt; echo "exit=$?"; ls -A work work/.stash/txt'
run 'cd work && ../stash.sh data.tar.gz Makefile; echo "exit=$?"; ls -A . .stash'
run './stash.sh "work/my notes.txt" work/sub/plan.txt; echo "exit=$?"; ls -AR work'
run './stash.sh work/nosuch work/sub work/report.txt; echo "exit=$?"'
