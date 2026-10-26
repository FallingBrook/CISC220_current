# Bash Sprint: a study plan for the CISC220 Bash midterm

A study app built from the course notebooks in `bash/`, the 2023 quizzes in `bash/Bash-Past-Tests/`, and the
assignments. It takes you from no Bash knowledge to ready for the 50-minute, closed-book midterm on
**Tuesday, October 27**.

## Open the app

Open `study-app/index.html` in a browser. It is a single file with no install and no server, and it saves your
progress in that browser. The same app is also published as a private web page; you can use either one, but
progress is saved separately in each, so stick to one. You can move progress between them with
*Progress & backup*.

## The plan

Days 1–2 went at a normal pace. Days 3–4 are crash days that cover the rest of the course notebooks, still in
the order of `start_here.ipynb`, with the time put where the marks are.

| Day | Date | What |
|---|---|---|
| 1 | Tue Oct 20 | Your first session in the terminal, history, command line intro, filesystem, commands |
| 2 | Wed Oct 21 | Filename expansion, quoting, files, permissions |
| 3 | Sun Oct 25 | Crash day 1: streams, expansions, intro to scripting, variables, strings, `tr`, regex |
| 4 | Mon Oct 26 | Crash day 2: arithmetic, arrays, conditional operators, `if`, loops, functions; mini mock (the two 10-mark questions); one-page summary |
| 5 | Tue Oct 27 | Exam morning: past-paper practice (every Bash question from the 2024 midterm, 2023 quizzes and past finals, plus a variant of each, marked by Claude), then a skim of your summary |

A crash day runs: a short spaced review, the lessons in order, a 25-question mixed quiz, the 7 *core* handwritten
scripts (the past-quiz questions plus one blank-page exercise per topic; the rest are marked as extras), and
flashcards. Terminal drills are optional on crash days. The full mock exams A and B stay available under
*Exam practice*.

The *Why the days are built this way* section of the plan page explains the research behind each step.

## Past-paper practice

`content/practice/` holds the Bash questions from the papers in `bash/Bash-Past-Tests/`, each followed by one close
variant: 86 questions. From the finals, only the questions Prof. Ma lists as relevant to this offering are included
(2014F Q1, 2015F Q1 and Q3, 2016F Q1; Q1 of April 2022 is excluded), and C questions are left out because the
midterm covers only Bash. The practice page
asks them one at a time. In the published web version, Claude marks each answer against the model answer, grading
notes and rubric, so any correct solution passes. In the local `index.html`, you mark yourself against the model
answer. Missed questions come back a few questions later until you get them right.

## Terminal drills (Ubuntu)

Do these after each day's lessons. The app's Day 1 drills page walks you through the setup one step at a time.

```bash
git clone -b claude/cisc220-bash-study-app-1w7tyo https://github.com/FallingBrook/CISC220_current.git ~/CISC220_current
cd ~/CISC220_current/study-app/drills
./drill.sh start 1      # prints Day 1's tasks, creates your answers file and a sandbox
./drill.sh check 1      # grades your answers
```

Your answers and scripts are kept in `~/cisc220_drills/`, outside the repository. The checker runs your answer
and the reference answer in identical throwaway sandboxes and compares the output and the resulting files, so
any correct command passes. Don't open `drills/days/` or `drills/solutions/` before you try the tasks: they
contain the answers.

## For maintainers

- Content: `content/dayN.json`, `content/mocks.json` and `content/cheatsheet.json`. The format is described in
  `content/SPEC.md`.
- App source: `src/app.js`, `src/app.css` and `src/head.html`. Run `python3 build.py` to rebuild `index.html`.
- Drill self-check: `./drill.sh selftest N` runs each reference answer and prints its output.
