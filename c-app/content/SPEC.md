# Content spec for the CISC220 C study app

The student finished the Bash half of CISC220 (Queen's University, Prof. Burton Ma). They know Bash, the terminal,
nano, and how to compile nothing yet: assume ZERO C knowledge. The C final exam is on December 10 (closed book,
handwritten code). Assignment 4 (concat2.c, sin.c, sumones.c) is due November 6. About one hour of study per day,
so each day's module is SHORT: 2 to 3 lessons of 5 to 10 minutes each.

Each day is one JSON file, `c-app/content/dayN.json`. Validate with `python3 -m json.tool`.

## Ground rules

* Follow the course notebooks in `c/*.ipynb` (and `c/src/`): same terminology, examples and conventions
  (C17, `gcc -Wall`, `int main(void)` / `int main(int argc, char *argv[])`, `size_t`, `%zu`).
* VERIFY every code example and every expected output by compiling with `gcc -std=c17 -Wall` and running it.
  Paste real output. Undefined behaviour must never be presented as having a fixed output.
* Beginner wording: short sentences, define each term when first used, build from simple to complex, explain *why*.
* Nothing may be used before it is taught (this day's earlier lessons, or earlier days listed in your instructions).
* Assignment 4 is graded: NEVER write the solution (or a near-complete solution) of concat2.c, sin.c or sumones.c, nor
  of their functions fact, print, tobinary, sum. Teach every needed skill with DIFFERENT worked examples (for example
  joining a string with itself, an e^x series, adding decimal digit strings), then give guided steps and hints that
  leave the actual writing to the student.
* On Ubuntu, `-lm` must come AFTER the source file: `gcc -o sin sin.c -lm`. The assignment's `gcc -o sin -lm sin.c`
  fails with "undefined reference to `pow`". Teach the working order and why (the linker reads left to right).

## Markdown

Paragraphs, `**bold**`, `*italic*`, `` `code` ``, `- ` lists, `1. ` lists, `### ` headings, ```` ```c ```` fences,
pipe tables, `[links](https://...)`. `\n` for new lines in JSON. No HTML. A code block whose lines start with `$ ` is
shown as a terminal session (`$ ` lines typed, other lines output).

## Schema

{
  "day": 1, "title": "...", "goal": "one sentence",
  "topics": [ { "id": "c1-hello", "title": "...", "notebook": "c/a_simple_c_program.ipynb", "priority": "high|medium|low",
                "examNote": "optional markdown",
                "blocks": [ {"type":"md","text":"..."}, {"type":"code","code":"...","caption":"optional"},
                            {"type":"check","q":"...","a":"..."}, {"type":"why","q":"...","a":"..."},
                            {"type":"pitfall","text":"..."}, {"type":"try","text":"hands-on step in the terminal"} ] } ],
  "flashcards": [ {"id":"c1-fc-01","topic":"c1-hello","front":"...","back":"..."} ],
  "quiz": [ {"id":"c1-q-01","topic":"...","type":"mcq","q":"...","options":["a","b","c","d"],"answer":0,"explain":"..."},
            {"id":"c1-q-02","topic":"...","type":"output","q":"What does this program print?","code":"...","answer":"exact output","explain":"..."},
            {"id":"c1-q-03","topic":"...","type":"short","q":"...","answer":"model answer","explain":"..."} ],
  "write": [ {"id":"c1-w-01","topic":"...","stage":"worked|faded|blank","marks":4,"prompt":"...","starter":"code with ____ (faded) or \"\"",
              "solution":"...","explain":"(required for worked)","rubric":[{"marks":1,"item":"..."}],"pitfalls":["..."]} ]
}

Sizes per day (short modules): 2–3 topics, each ending with an md block headed `### Key points`;
12–18 flashcards; 10–14 quiz items (mostly `output` and `short`); 3 writing items (worked, faded, blank).
IDs: `cN-fc-NN`, `cN-q-NN`, `cN-w-NN`, topic ids `cN-<slug>`.

## Labs (`c-app/drills/days/dayN.sh`), run with `./cdrill.sh` (read `c-app/drills/cdrill.sh` first)

The student writes small C programs in `~/cisc220_c/dayN/`; the checker compiles them with
`gcc -std=c17 -Wall` (plus `-lm` if the task says so) and compares stdout, stderr and exit status with your
reference solution in `c-app/drills/solutions/dayN/`, test by test, so any correct program passes.

    DAY_TITLE="..."
    ctask 1 hello.c "Prompt (plain text): what the program must do, exact output format, exit status."
    crun ''                 # one test: command line arguments as shell words ('' = none)
    crun 'abc "two words"'
    crun '' 'line one\nline two\n'   # optional 2nd argument: standard input (printf %b escapes)
    compare out,status      # optional, default out,err,status
    libs -lm                # optional, extra link flags

3–5 tasks per day, each with 3+ tests including edge cases. Do NOT make labs that are the assignment programs.
Run `CISC220_C_HOME=<scratch dir> ./cdrill.sh selftest N` to check every reference compiles and gives the intended output.
