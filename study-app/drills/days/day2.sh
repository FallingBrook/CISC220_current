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

task 1 cmd home/user1/pics "Using ls, list every file in pics whose name ends in .jpg (lowercase extension only). Remember one of them has a space in its name."
ref 'ls *.jpg'
compare out

task 2 cmd home/user1/pics "Using ls, list every file in pics whose name ends in .jpg in ANY mix of upper and lower case (.jpg, .JPG, .Jpg, ...). Use a single pattern."
ref 'ls *.[jJ][pP][gG]'
compare out

task 3 cmd home/user1/pics "Using echo and a glob, print the names of the hidden entries in pics on one line. Do NOT print . or .. (hint: a hidden name starts with a dot followed by a character that is not a dot)."
ref 'echo .[!.]*'
compare out

task 4 cmd "home/user1/pics" "Rename the file named my photo.jpg to my_photo.jpg."
ref 'mv "my photo.jpg" my_photo.jpg'

task 5 cmd home/user1/marking/A1 "From marking/A1, list all files named A1answers.txt found directly inside the student directories (not inside subdirectories of the student directories) using a single ls command."
ref 'ls */A1answers.txt'
compare out

task 6 cmd home/user1/marking/A1 "From marking/A1, list all files, INCLUDING hidden files, in every subdirectory of A1 (one ls command, like Quiz 1 Q1F)."
ref 'ls -a */'
compare out

task 7 cmd home/user1/marking/A1 "Late submissions are marked by hidden files: .late (1 day), .late+ (2 days), .late++ and .late+x (3 or more days). From marking/A1, use ls -1 to list the late-marker files of the students who were late by 2 days or more (that is .late+, .late++ and .late+x but NOT .late)."
ref 'ls -1 */.late+*'
compare out

task 8 cmd home/user1/marking/A1 "From marking/A1, list (one per line, with ls -1d) every file or directory inside the student directories whose name starts with a or A followed by 1. Use -d so that directories are not opened."
ref 'ls -1d */[aA]1*'
compare out

task 9 cmd home/user1/docs "Print the contents of the file named meeting notes.txt."
ref 'cat "meeting notes.txt"'
compare out

task 10 cmd home/user1/docs "Using ls, list only the draft files whose number is a single digit (draft1.txt and draft2.txt but not draft10.txt)."
ref 'ls draft?.txt'
compare out

task 11 cmd home/user1/docs "The PDF files have permissions r-------- (400). With ONE chmod command, change every file ending in .pdf or .PDF to rw-r--r-- using SYMBOLIC permissions (like Assignment 1 Q15)."
ref 'chmod u+w,go+r *.pdf *.PDF'

task 12 cmd home/user1/docs "In ONE line, create a directory named pdfs and move every file ending in .pdf or .PDF into it (you may join two commands with && or ;)."
ref 'mkdir pdfs && mv *.pdf *.PDF pdfs'

task 13 cmd home/user1 "From home/user1, copy the directory lectures and everything in it to a new directory named lectures_copy."
ref 'cp -r lectures lectures_copy'

task 14 cmd home/user1 "From home/user1, create the directory projects/2026/fall/cisc220 (none of these directories exist yet) with a single command."
ref 'mkdir -p projects/2026/fall/cisc220'

task 15 cmd home/user1 "From home/user1, in ONE line: remove the empty directory old, the file tmp.sh, and the directory junk together with everything inside it."
ref 'rmdir old && rm tmp.sh && rm -r junk'

task 16 cmd home/user1/scripts "Using an OCTAL mode, set the permissions of hello.sh to rwxr-x--- ."
ref 'chmod 750 hello.sh'

task 17 cmd home/user1/scripts "With ONE chmod command using SYMBOLIC permissions, give the owner execute permission on every .sh file and remove write permission for group and other (leave every other permission as it is)."
ref 'chmod u+x,go-w *.sh'

task 18 cmd home/user1/scripts "Print the three-digit octal permissions of run.sh (the command used in Assignment 2 and Quiz 1 Q4)."
ref 'stat -c %a run.sh'
compare out

task 19 text . "Write the octal mode for the permissions rwxr-x--x ."
accept '751'

task 20 text . "Write the 9-character permission string (like rwxr-xr-x) for octal mode 640."
accept 'rw-r-----'
