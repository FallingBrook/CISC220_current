# Bash Sprint: an 8-day plan for the CISC220 Bash midterm

A study app built from the course notebooks in `bash/`, the 2023 quizzes in `bash/Bash-Past-Tests/`, and the
assignments. It takes you from no Bash knowledge to ready for the 50-minute, closed-book midterm on
**Tuesday, October 27**.

## Open the app

Open `study-app/index.html` in a browser. It is a single file with no install and no server, and it saves your
progress in that browser. The same app is also published as a private web page; you can use either one, but
progress is saved separately in each, so stick to one. You can move progress between them with
*Progress & backup*.

## The plan

| Day | Date | Topics |
|---|---|---|
| 1 | Mon Oct 19 | Terminal basics, filesystem and paths, commands, exit status |
| 2 | Tue Oct 20 | Globs, quoting, cp/mv/rm/mkdir, permissions and chmod |
| 3 | Wed Oct 21 | Streams, redirection, pipelines and tee, expansions, tr |
| 4 | Thu Oct 22 | Scripts, `$1 $# $@`, variables, string expansions, arithmetic |
| 5 | Fri Oct 23 | Regular expressions, `[[ ]]` tests, if/elif/case |
| 6 | Sat Oct 24 | Arrays, loops, functions |
| 7 | Sun Oct 25 | Mock exam A (timed, on paper), test your scripts, fix weak spots |
| 8 | Mon Oct 26 | Mock exam B, your own summary sheet, early night |

Each day of new material follows the same routine of about 2.5 hours:

1. **Spaced review** of earlier days (from Day 2 on)
2. **Lessons** with *Check* questions to answer before you reveal each answer
3. **Flashcards**, rated Again / Hard / Good / Easy
4. **Practice quiz**, mixed with earlier days' questions from Day 3 on
5. **Write it by hand**: a worked example, then one with blanks, then a blank page
6. **Terminal drills**, auto-graded in a real shell
7. **Brain dump**: write everything you remember, then compare with the key points

The *Why the days are built this way* section of the plan page explains the research behind each step.

## Terminal drills (Ubuntu)

```bash
git clone -b claude/cisc220-bash-study-app-1w7tyo https://github.com/FallingBrook/CISC220_current.git ~/CISC220_current
cd ~/CISC220_current/study-app/drills
./drill.sh start 0      # 5-minute warm-up that shows how drills work
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
