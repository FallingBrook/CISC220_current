# C Sprint: a day-by-day C course for the CISC220 final

A study app built from the course's C notebooks in `c/`, Assignment 4, and the past finals in
`bash/Bash-Past-Tests/`. It starts from no C knowledge on November 1, gets you through Assignment 4 (due
November 6), and prepares you for the closed-book, handwritten **C final on Thursday, December 10**. About an
hour a day.

## Open the app

Open `c-app/index.html` in a browser, or use the published web page (Claude marks your practice answers there).
Progress is saved in that browser; move it with *Progress & backup*.

## The plan

| Days | Dates | What |
|---|---|---|
| 1–5 | Nov 1–5 | First program, types and control flow, strings and argv (concat2.c), functions and math (sin.c), binary and array parameters (sumones.c) |
| 6 | Nov 6 | Assignment 4 due: final checks and submit |
| 7–14 | Nov 7–14 | Scope, integers, bitwise operations, floating point, pointers, structs, arrays in depth |
| 15 | Nov 15 | Review day |
| 16–21 | Nov 16–21 | Strings, dynamic memory, a string data type |
| 22 | Nov 22 | Review day |
| 23–27 | Nov 23–27 | Linked stack, generic stack (deleting a node), file I/O |
| 28 | Nov 28 | Review day |
| 29–38 | Nov 29 – Dec 8 | Past-exam practice |
| 39–40 | Dec 9–10 | Summary sheet, early night, exam |

Each lesson day has short lessons with check questions and hands-on steps, flashcards on a spaced schedule, a quick
quiz, three handwriting exercises (worked, fill in the blanks, blank page), and an optional lab.

## Labs and the Assignment 4 checker

```bash
cd ~/CISC220_current/c-app/drills
./cdrill.sh start 3          # shows Day 3's lab tasks and makes ~/cisc220_c/day3/
./cdrill.sh check 3          # compiles your programs and tests them against reference programs
./cdrill.sh a4               # tests ~/CISC220_A4/concat2.c, sin.c and sumones.c against the assignment's examples
```

The A4 checker contains only expected outputs from the assignment, never solution code. Don't open
`drills/days/` or `drills/solutions/` before trying the labs: they contain the answers.

Compile `sin.c` and `sumones.c` with `-lm` **after** the source file (`gcc -o sin sin.c -lm`); the assignment's
`gcc -o sin -lm sin.c` fails to link on Ubuntu.

## Past-exam practice

`content/practice/` holds the C questions Prof. Ma lists as relevant from the papers available here (2014F Q3, Q4,
Q6, Q7; 2015F Q4, Q6; 2016F Q3, Q4, Q5; April 2022 Q2–Q6), each followed by a close variant: 50 questions. Papers
on his list that aren't in the repo yet: 2016F2, 2017F, 2018F, 2019F, April 2023.

## For maintainers

- Plan: `content/plan.json`. Lessons: `content/dayN.json` (format in `content/SPEC.md`). Summary sheet:
  `content/cheatsheet.json`.
- App source: `src/`. Run `python3 build.py` to rebuild `index.html` and `dist/artifact.html`.
- Check a lab day's references: `./cdrill.sh selftest N`.
