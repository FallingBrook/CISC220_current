# Content spec for the CISC220 Bash study app

The student is starting from **zero** Bash knowledge. The 50-minute, closed-book midterm is on Oct 27 and has
short answers plus **scripts written by hand on paper** (about half the marks). It covers all of the Bash
notebooks in `bash/`. History and Unix philosophy are low priority.

Each day of study is one JSON file, `study-app/content/dayN.json`. The web app renders it. The file must be
valid JSON (check with `python3 -m json.tool dayN.json > /dev/null`).

## Ground rules

* **Everything must agree with the course notebooks** (`bash/*.ipynb`). Read the notebooks for your topics
  completely, including the scripts in `bash/scripts/<topic>/`. Use the notebooks' terminology, examples and
  conventions (for example, functions are written `name() { ... }`, tests use `[[ ]]` and `(( ))`). Do not
  teach commands the course does not use (no `find`, `awk`, `sed`, etc., unless a notebook teaches them).
* **Verify every code example and every expected output by actually running it in bash** (GNU/Linux, bash 5).
  An answer key with a wrong output is the worst possible bug in this app.
* Write for a beginner: short sentences, define each term the first time, build up from simple to complex.
  Explain *why* things work, not only *what* to type.
* Mirror the exam style. Past tests: `quiz1_2023.txt`, `quiz2_2023.txt`; assignments: `assignments.md`
  (paths given in your instructions). Use them to judge what is important and to write similar (not identical)
  questions. Note that the posted Quiz 1 solution's last line `mv "$pathname $trashdir"` is a typo; the correct
  line is `mv "$pathname" "$trashdir"`.
* Quote variables (`"$var"`) in all model answers, as the course requires.

## Markdown

All text fields are a small Markdown subset: paragraphs, `**bold**`, `*italic*`, `` `inline code` ``,
`- ` bullet lists, `1. ` numbered lists, `### ` headings, fenced code blocks (```` ```bash ````), simple pipe
tables (header row, `|---|` separator row, body rows), and `[links](https://...)`. Use `\n` for new lines in JSON
strings. No HTML.

## Schema

```json
{
  "day": 1,
  "title": "Short title of the day",
  "goal": "One sentence: what you can do after today.",
  "topics": [
    {
      "id": "d1-filesystem",
      "title": "The Linux filesystem",
      "notebook": "bash/filesystem.ipynb",
      "priority": "high",
      "examNote": "How this showed up on past tests and assignments (optional, markdown).",
      "blocks": [
        { "type": "md", "text": "Explanation (markdown)." },
        { "type": "code", "code": "$ pwd\n/home/user1", "caption": "optional caption" },
        { "type": "check", "q": "Retrieval question asked mid-lesson.", "a": "Its answer." },
        { "type": "why", "q": "A *why* question (elaborative interrogation).", "a": "The explanation." },
        { "type": "pitfall", "text": "A common mistake and how to avoid it." },
        { "type": "try", "text": "A hands-on step to do now in the terminal." }
      ]
    }
  ],
  "flashcards": [
    { "id": "d1-fc-01", "topic": "d1-filesystem", "front": "Question side", "back": "Answer side" }
  ],
  "quiz": [
    { "id": "d1-q-01", "topic": "d1-filesystem", "type": "mcq", "q": "Question",
      "options": ["A", "B", "C", "D"], "answer": 2, "explain": "Why C is right and the others are wrong." },
    { "id": "d1-q-02", "topic": "d1-filesystem", "type": "output", "q": "What does this print?",
      "code": "echo a b", "answer": "a b", "explain": "..." },
    { "id": "d1-q-03", "topic": "d1-filesystem", "type": "short", "q": "Question",
      "answer": "Model answer (markdown)", "explain": "..." }
  ],
  "write": [
    { "id": "d1-w-01", "topic": "d1-filesystem", "stage": "worked", "marks": 4,
      "prompt": "Exam-style task (markdown).",
      "starter": "Code with ____ blanks (faded stage), or empty string",
      "solution": "#!/bin/bash\n...",
      "explain": "Walkthrough of the solution (required for worked stage, optional otherwise).",
      "rubric": [ { "marks": 1, "item": "What earns this mark" } ],
      "pitfalls": ["Mistake to avoid"],
      "core": true }
  ]
}
```

Field notes:

* `priority`: `high`, `medium` or `low`: how likely the topic is to be tested, judged from the past tests.
* `blocks`: each topic's lesson. Interleave explanation with `code`, and put a `check` after every main idea
  (about one per 150-250 words of explanation). Use `code` blocks as terminal transcripts (`$ ` prompt lines then
  output) or as scripts. Each topic should end with a short `md` block headed `### Key points` (3-6 bullets).
* `quiz.type`:
  * `mcq`: 4 options, `answer` is a 0-based index. Make the wrong options plausible misconceptions.
  * `output`: "what does this print?" `answer` is the **exact** output (lines joined with `\n`). The app
    compares after trimming trailing whitespace and lets the student mark themselves right. Only use
    deterministic code. Assume a stated sandbox if files are needed (describe the files in `q`).
  * `short`: free-response; the student types an answer, then marks it against the model `answer`.
    Use these for "what single command would you use to ..." questions; accept-alternatives belong in `explain`.
* `write.stage`: exercises go in order `worked` (full solution shown with `explain`; the student studies it,
  then copies it out from memory), `faded` (`starter` has the structure with key parts replaced by `____`),
  `blank` (from scratch, exam style, with `marks` and a rubric that totals `marks`).
* `core` (optional): marks the writing exercises a crash day treats as essential; the others are shown as extras.
* IDs must be unique and stable: `dN-fc-NN`, `dN-q-NN`, `dN-w-NN`, topic ids `dN-<slug>`.

## Terminal drills (`study-app/drills/days/dayN.sh`)

Each day also has drills run with `./drill.sh` (read `study-app/drills/drill.sh` and an existing `days/dayN.sh` first).
The student writes one-line answers in an answers file, and scripts in a folder. Each answer is graded by
running it and the reference answer in identical fresh sandboxes and comparing the results, so **any correct
command passes**.

```bash
DAY_TITLE="..."
setup_sandbox() {        # build the files the tasks need, cwd = empty sandbox root
    mkdir -p home/user1/courses/CISC220
    printf 'Cade\tBarry\t3100025\n' > classlist
    chmod 600 secret.txt
}
task 1 cmd home/user1 "Prompt shown to the student (plain text, no markdown)."
ref 'ls -a courses'
compare out          # optional: out, err, status, fs (default for cmd: out,fs)

task 2 text . "Short-answer prompt."
accept 'answer one'
accept 'answer two'     # exact match after squeezing spaces; keep these for unambiguous answers

task 3 script home/user1 "Prompt for a script (plain text; give exact output and exit status requirements)."
file trash.sh            # the reference solution goes in drills/solutions/dayN/trash.sh
run './trash.sh ./notes.txt; ls -A .trash'
run './trash.sh; echo "exit=$?"'
```

Rules:

* The sandbox root stands in for `/`. Tasks that need an absolute path should say "use `$SB/...`" in place of
  `/...` (`$SB` is set to the sandbox root when tasks run). `$HOME` is also the sandbox root during grading.
* Prompts must state the working directory and anything else needed to get a unique result. When a command
  changes files (cp, mv, mkdir, chmod), its effect is checked through the `fs` snapshot (names, types, octal
  permissions, sizes, contents). When it only prints, use `compare out`.
* Commands that print `ls` listings are fine (timestamps are fixed). Avoid anything that depends on the current
  date, the user name, random numbers, or the machine.
* `run` commands for scripts can use pipes, `;`, `echo $?`, `ls`, `cat` etc. to expose the result. Include
  edge cases the exam would care about (spaces in filenames, no arguments, missing files).
* Afterwards run `./drill.sh selftest N` and check that every reference produces the output you intended (no
  "No such file" errors unless intended). Also try a wrong answer and a correct alternative answer for a
  couple of tasks with `CISC220_DRILLS_HOME=<scratch dir> ./drill.sh start N`, editing the answers file, then
  `./drill.sh check N`.
* About 12-20 tasks per day, mixing `cmd`, `text` and (from Day 3 on) `script` tasks.
