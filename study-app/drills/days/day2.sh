# Day 2: globs, quoting, managing files, permissions.
DAY_TITLE="Globs, quoting, managing files, permissions"

setup_sandbox() {
    mkdir -p home/user1
    cd home/user1 || return

    # pics: mixed case, spaces, hidden files
    mkdir -p pics/.thumbs
    touch pics/IMG_01.jpg pics/IMG_02.JPG pics/IMG_10.jpg pics/img_03.jpg pics/holiday.png \
          'pics/my photo.jpg' pics/.cache pics/.index pics/.thumbs/t1.jpg

    # marking/A1: student directories like Assignment 1 (one name has a space)
    mkdir -p marking/A1/Anita_Job/__MACOSX marking/A1/Betty_Diddit 'marking/A1/Justin Case' \
             marking/A1/Luke_Warme marking/A1/Rose
    echo "Anita's answers" > marking/A1/Anita_Job/A1answers.txt
    touch marking/A1/Anita_Job/a1notes.txt marking/A1/Anita_Job/__MACOSX/A1answers.txt
    echo "Betty's answers" > marking/A1/Betty_Diddit/A1answers.txt
    touch marking/A1/Betty_Diddit/.late marking/A1/Betty_Diddit/A1_extra.sh
    echo "Justin's answers" > 'marking/A1/Justin Case/A1answers.txt'
    touch 'marking/A1/Justin Case/.late++'
    echo "Luke's answers" > marking/A1/Luke_Warme/A1answers.txt
    touch marking/A1/Luke_Warme/.acc marking/A1/Luke_Warme/.late+
    touch marking/A1/Rose/a1.sh marking/A1/Rose/.late+x
    touch marking/A1/notes.txt

    # docs: .pdf and .PDF, numbered drafts, a file with spaces and one with a * in its name
    mkdir -p docs
    echo "pdf one" > docs/report.pdf
    echo "PDF two" > docs/Summary.PDF
    echo "pdf three" > docs/slides.pdf
    touch docs/draft1.txt docs/draft2.txt docs/draft10.txt docs/notes.txt docs/.secret
    echo "agenda: midterm review" > 'docs/meeting notes.txt'
    echo "a star is in my name" > 'docs/file_with_*_in_name'
    chmod 400 docs/report.pdf docs/Summary.PDF docs/slides.pdf

    # scripts with assorted permissions
    mkdir -p scripts
    printf '#!/bin/bash\necho hello\n' > scripts/hello.sh
    printf '#!/bin/bash\necho build\n' > scripts/build.sh
    printf '#!/bin/bash\necho run\n' > scripts/run.sh
    chmod 644 scripts/hello.sh
    chmod 664 scripts/build.sh
    chmod 604 scripts/run.sh

    # things to copy, make and remove
    mkdir -p lectures/week1 old junk/sub
    echo "intro" > lectures/week1/intro.txt
    echo "globs" > lectures/globs.txt
    touch junk/a junk/sub/b tmp.sh
}

task 1 cmd home/user1/pics "The current directory is pics. Using ls and a wildcard pattern, list every file whose name ends in .jpg (lowercase .jpg only). One of the names contains a space; a pattern handles that without any quoting."
ref 'ls *.jpg'
compare out

task 2 cmd home/user1/pics "The current directory is pics. Using ls and ONE wildcard pattern, list every file whose name ends in .jpg in any mix of upper and lower case (.jpg, .JPG, .Jpg, and so on)."
ref 'ls *.[jJ][pP][gG]'
compare out

task 3 cmd home/user1/pics "The current directory is pics. Using echo and a wildcard pattern, print the names of the hidden entries (names starting with a dot) on one line. Do NOT print . or .. (hint: write a dot, then one character that is not a dot, then anything)."
ref 'echo .[!.]*'
compare out

task 4 cmd home/user1/pics "The current directory is pics. Rename the file whose name is my photo.jpg (with a space between my and photo) to my_photo.jpg."
ref 'mv "my photo.jpg" my_photo.jpg'

task 5 cmd home/user1/marking/A1 "The current directory is marking/A1, which holds one directory per student. Using a single ls command, list every file named A1answers.txt that is directly inside a student directory (not deeper, so not the one inside __MACOSX)."
ref 'ls */A1answers.txt'
compare out

task 6 cmd home/user1/marking/A1 "The current directory is marking/A1. With one ls command, list all the files, INCLUDING hidden files, in every subdirectory of A1 (like Quiz 1 Q1F)."
ref 'ls -a */'
compare out

task 7 cmd home/user1/marking/A1 "The current directory is marking/A1. Late submissions are marked by hidden files inside the student directories: .late (1 day), .late+ (2 days), .late++ and .late+x (3 or more days). Use ls -1 and one wildcard pattern to list, one per line, the files .late+, .late++ and .late+x of every student, but NOT .late."
ref 'ls -1 */.late+*'
compare out

task 8 cmd home/user1/marking/A1 "The current directory is marking/A1. Using ls -1d and a wildcard pattern, list (one per line) everything inside the student directories whose name starts with a or A followed by 1. The -d option makes ls print a matching directory's name instead of its contents."
ref 'ls -1d */[aA]1*'
compare out

task 9 cmd home/user1/docs "The current directory is docs. Print the contents of the file whose name is meeting notes.txt (with a space)."
ref 'cat "meeting notes.txt"'
compare out

task 10 cmd home/user1/docs "The current directory is docs. Using ls and a wildcard pattern, list only the draft files whose number has one digit (draft1.txt and draft2.txt, but not draft10.txt)."
ref 'ls draft?.txt'
compare out

task 11 cmd home/user1/docs "The current directory is docs. The PDF files have permissions r-------- (octal 400). With ONE chmod command using a SYMBOLIC mode (letters such as u+w, not digits), change every file ending in .pdf or .PDF to rw-r--r-- (like Assignment 1 Q15)."
ref 'chmod u+w,go+r *.pdf *.PDF'

task 12 cmd home/user1/docs "The current directory is docs. On ONE line, create a directory named pdfs and then move every file ending in .pdf or .PDF into it (join the two commands with && or ;)."
ref 'mkdir pdfs && mv *.pdf *.PDF pdfs'

task 13 cmd home/user1 "The current directory is home/user1. Copy the directory lectures and everything in it to a new directory named lectures_copy."
ref 'cp -r lectures lectures_copy'

task 14 cmd home/user1 "The current directory is home/user1. With a single command, create the directory projects/2026/fall/cisc220 (none of projects, 2026, fall or cisc220 exist yet)."
ref 'mkdir -p projects/2026/fall/cisc220'

task 15 cmd home/user1 "The current directory is home/user1. On ONE line (join commands with && or ;), remove the empty directory old, the file tmp.sh, and the directory junk together with everything inside it."
ref 'rmdir old && rm tmp.sh && rm -r junk'

task 16 cmd home/user1/scripts "The current directory is scripts. Using an OCTAL mode (digits), set the permissions of hello.sh to rwxr-x--- ."
ref 'chmod 750 hello.sh'

task 17 cmd home/user1/scripts "The current directory is scripts. With ONE chmod command using a SYMBOLIC mode, give the owner execute permission on every file ending in .sh, and remove write permission for group and other. Every other permission must stay as it is."
ref 'chmod u+x,go-w *.sh'

task 18 cmd home/user1/scripts "The current directory is scripts. Print the permissions of run.sh as an octal number (the stat command used in Assignment 2 and Quiz 1 Q4)."
ref 'stat -c %a run.sh'
compare out

task 19 text . "Short answer (no command): write the octal mode for the permissions rwxr-x--x ."
accept '751'

task 20 text . "Short answer (no command): write the 9-character permission string (like rwxr-xr-x) for octal mode 640."
accept 'rw-r-----'
