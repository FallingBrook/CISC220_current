# Day 0: learn how the drills work (5 minutes). Do this before Day 1.
DAY_TITLE="How drills work (warm-up)"

setup_sandbox() {
    mkdir -p home/user1/notes home/user2
    echo "hello from the sandbox" > home/user1/notes/welcome.txt
    echo "a second file" > home/user1/notes/second.txt
}

task 1 cmd home/user1 "Print the contents of the file welcome.txt, which is inside the notes directory. (Answer: cat notes/welcome.txt)"
ref 'cat notes/welcome.txt'

task 2 cmd home/user1 "Create a new directory named drafts in the current directory."
ref 'mkdir drafts'

task 3 text . "In a path, what single character is the name of the root directory?"
accept '/'

task 4 script home/user1 "Write a script greet.sh that prints: Hello, NAME! where NAME is the first command line argument. Example: ./greet.sh Sam prints Hello, Sam!"
file greet.sh
run './greet.sh Sam'
run './greet.sh "Mary Ann"'
