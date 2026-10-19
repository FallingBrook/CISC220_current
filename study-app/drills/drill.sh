#!/usr/bin/env bash
#
# drill.sh -- hands-on terminal drills for the CISC220 Bash study app
#
# Usage:
#   ./drill.sh list             list the drill days
#   ./drill.sh start N          set up day N: prints the tasks, creates your answers file,
#                               your scripts folder, and a sandbox you can explore
#   ./drill.sh show N           print the tasks for day N again
#   ./drill.sh check N [ID]     grade your answers for day N (optionally only task ID)
#   ./drill.sh sandbox N        rebuild a fresh copy of the day N sandbox to explore
#   ./drill.sh selftest N       (for maintainers) grade the reference solutions against themselves
#
# Your work lives outside the repository, in ~/cisc220_drills (override with CISC220_DRILLS_HOME):
#   ~/cisc220_drills/answers/dayN.txt     one-line command answers
#   ~/cisc220_drills/scripts/dayN/*.sh    scripts you write
#   ~/cisc220_drills/play/dayN/           a sandbox to explore and test commands in
#
# How grading works: each task is run twice in an identical, freshly built sandbox, once with
# the reference answer and once with yours. Your answer passes if it produces the same output
# (and leaves the files in the same state) as the reference answer. Different commands that do
# the same thing pass, just like on the exam.

set -u

DRILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_ROOT="${CISC220_DRILLS_HOME:-$HOME/cisc220_drills}"
SANDBOX="$WORK_ROOT/.grading/sandbox"
TMP="$WORK_ROOT/.grading/tmp"

if [[ -t 1 ]]; then
    B=$'\e[1m'; G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; D=$'\e[2m'; N=$'\e[0m'
else
    B=; G=; R=; Y=; D=; N=
fi

# ---------------------------------------------------------------------------
# Task definition language used by days/dayN.sh
#
#   task ID KIND CWD "PROMPT"    KIND is cmd, script, or text; CWD is relative to the sandbox root
#   ref 'COMMAND'                (cmd) the reference answer
#   compare out,fs               what to compare: any of out, err, status, fs
#                                (cmd default: out,fs   script default: out,err,status,fs)
#   file NAME                    (script) the file the student writes; solution in solutions/dayN/NAME
#   run 'COMMAND'                (script) one test; run from CWD with the script copied into CWD
#   accept 'ANSWER'              (text) an accepted answer; may be given several times
#   setup_sandbox() { ... }      builds the sandbox; called with the empty sandbox root as cwd
# ---------------------------------------------------------------------------

declare -a T_IDS=()
declare -A T_KIND=() T_CWD=() T_PROMPT=() T_REF=() T_CMP=() T_FILE=() T_RUNS=() T_ACCEPT=()
CUR=""
DAY_TITLE=""

task() {
    CUR=$1
    T_IDS+=("$1")
    T_KIND[$1]=$2
    T_CWD[$1]=$3
    T_PROMPT[$1]=$4
    T_RUNS[$1]=""
    T_ACCEPT[$1]=""
    if [[ $2 == script ]]; then T_CMP[$1]=out,err,status,fs; else T_CMP[$1]=out,fs; fi
}
ref()     { T_REF[$CUR]=$1; }
compare() { T_CMP[$CUR]=$1; }
file()    { T_FILE[$CUR]=$1; }
run()     { T_RUNS[$CUR]+="$1"$'\x1e'; }
accept()  { T_ACCEPT[$CUR]+="$1"$'\x1e'; }
setup_sandbox() { :; }

die() { echo "${R}error:${N} $*" >&2; exit 1; }

load_day() {
    DAY=$1
    [[ $DAY =~ ^[0-9]+$ ]] || die "day must be a number, e.g. ./drill.sh start 1"
    local f="$DRILLS_DIR/days/day$DAY.sh"
    [[ -f $f ]] || die "no drills for day $DAY (try ./drill.sh list)"
    # shellcheck source=/dev/null
    source "$f"
}

# Build the sandbox for the loaded day at path $1 with deterministic timestamps.
build_at() {
    rm -rf "$1"
    mkdir -p "$1"
    (cd "$1" && setup_sandbox) >/dev/null 2>&1
    find "$1" -exec touch -h -d '2026-09-15 10:00:00' {} + 2>/dev/null
}

# Snapshot of the sandbox state: names, types, permissions, sizes, and contents.
# $1 is a path (relative to the sandbox root) to leave out, e.g. the script under test.
snapshot() {
    (
        cd "$SANDBOX" || exit
        local excl="./${1:-.no-such-file.}"
        find . -mindepth 1 ! -path "$excl" -printf '%p|%y|%m|%s\n' | LC_ALL=C sort
        find . -type f ! -path "$excl" -exec md5sum {} + 2>/dev/null | LC_ALL=C sort -k2
    )
}

# run_case CWD COMMAND OUTPREFIX [SCRIPTFILE SCRIPTSRC]
run_case() {
    local cwd=$1 cmd=$2 out=$3 sfile=${4:-} ssrc=${5:-}
    build_at "$SANDBOX"
    mkdir -p "$SANDBOX/$cwd"
    if [[ -n $sfile ]]; then
        cp "$ssrc" "$SANDBOX/$cwd/$sfile"
        chmod 755 "$SANDBOX/$cwd/$sfile"
    fi
    (
        cd "$SANDBOX/$cwd" || exit
        SB="$SANDBOX" HOME="$SANDBOX" timeout 5 bash -c "$cmd" >"$out.out" 2>"$out.err" </dev/null
        echo $? >"$out.status"
    )
    local rel=""
    [[ -n $sfile ]] && rel="${cwd%/}/$sfile" && rel=${rel#./}
    snapshot "$rel" >"$out.fs"
}

# Compare two run results ($1 = expected prefix, $2 = actual prefix) on the parts in $3.
# Prints a short diff for the first mismatching part and returns 1 on mismatch.
compare_runs() {
    local exp=$1 act=$2 parts=$3 p label
    IFS=, read -ra plist <<<"$parts"
    for p in "${plist[@]}"; do
        case $p in
            out) label="standard output" ;;
            err) label="standard error" ;;
            status) label="exit status" ;;
            fs) label="files left in the sandbox" ;;
            *) continue ;;
        esac
        if ! cmp -s "$exp.$p" "$act.$p"; then
            echo "      ${Y}$label differs${N} (${R}-expected${N} ${G}+yours${N}):"
            diff -u "$exp.$p" "$act.$p" | tail -n +4 | head -n 15 | sed 's/^/        /'
            return 1
        fi
    done
    return 0
}

answers_file() { echo "$WORK_ROOT/answers/day$DAY.txt"; }
scripts_dir()  { echo "$WORK_ROOT/scripts/day$DAY"; }

# Pull the answer for task $1 out of the answers file: the first non-comment,
# non-blank line after the "### ID" header.
get_answer() {
    local id=$1 f
    f=$(answers_file)
    [[ -f $f ]] || return 0
    awk -v id="$id" '
        /^### / { inside = ($2 == id); next }
        inside && !/^[[:space:]]*#/ && NF { print; exit }
    ' "$f"
}

print_prompt() {
    local id=$1 kind=${T_KIND[$1]} where
    where="sandbox/${T_CWD[$id]#./}"
    [[ ${T_CWD[$id]} == . ]] && where="sandbox root"
    case $kind in
        cmd)    echo "${B}[$id]${N} ${D}(command; run from: $where)${N}" ;;
        script) echo "${B}[$id]${N} ${D}(script: write $(scripts_dir)/${T_FILE[$id]})${N}" ;;
        text)   echo "${B}[$id]${N} ${D}(short answer)${N}" ;;
    esac
    printf '%s\n' "${T_PROMPT[$id]}" | fold -s -w 92 | sed 's/^/    /'
    echo
}

cmd_list() {
    local f n
    for f in "$DRILLS_DIR"/days/day*.sh; do
        n=${f##*/day}; n=${n%.sh}
        (
            source "$f"
            printf '  day %-2s %s (%d tasks)\n' "$n" "$DAY_TITLE" "${#T_IDS[@]}"
        )
    done | sort -n -k2
}

cmd_show() {
    echo "${B}Day $DAY drills: $DAY_TITLE${N}"
    echo
    local id
    for id in "${T_IDS[@]}"; do print_prompt "$id"; done
}

make_play() {
    local dir="$WORK_ROOT/play/day$DAY"
    build_at "$dir"
    echo "$dir"
}

cmd_start() {
    mkdir -p "$WORK_ROOT/answers" "$(scripts_dir)"
    local f id
    f=$(answers_file)
    if [[ ! -f $f ]]; then
        {
            echo "# Day $DAY drills: $DAY_TITLE"
            echo "#"
            echo "# Write each answer on the empty line under its ### header (one line per answer)."
            echo "# Lines starting with # are ignored. Check your work with:  ./drill.sh check $DAY"
            echo "# Absolute paths: in these drills the sandbox folder stands in for /. If an answer"
            echo "# needs an absolute path, start it with \$SB instead of /, e.g. \$SB/home/user1 for /home/user1."
            for id in "${T_IDS[@]}"; do
                [[ ${T_KIND[$id]} == script ]] && continue
                echo
                echo "### $id"
                printf '%s\n' "${T_PROMPT[$id]}" | fold -s -w 90 | sed 's/^/# /'
                echo
            done
        } >"$f"
    fi
    local play
    play=$(make_play)
    cmd_show
    echo "${B}Your files${N}"
    echo "  answers:  $f"
    echo "  scripts:  $(scripts_dir)/"
    echo "  sandbox:  $play"
    echo
    echo "Explore the sandbox (in a second terminal tab):   cd ${play/#$HOME/\~}"
    if [[ ${T_PROMPT[*]} == *'$SB'* ]]; then
        echo "  Some tasks use \$SB (the sandbox folder). In that tab, first run:   SB=${play/#$HOME/\~}"
    fi
    echo "Grade your work:                                  ./drill.sh check $DAY"
}

cmd_check() {
    local only=${1:-} selftest=${2:-} id kind ans pass=0 total=0 ok i src
    mkdir -p "$TMP"
    echo "${B}Day $DAY drills: $DAY_TITLE${N}"
    for id in "${T_IDS[@]}"; do
        [[ -n $only && $id != "$only" ]] && continue
        kind=${T_KIND[$id]}
        total=$((total + 1))
        ok=1
        case $kind in
            cmd)
                if [[ -n $selftest ]]; then ans=${T_REF[$id]}; else ans=$(get_answer "$id"); fi
                if [[ -z $ans ]]; then
                    echo "${Y}  ? $id${N} no answer yet"
                    continue
                fi
                run_case "${T_CWD[$id]}" "${T_REF[$id]}" "$TMP/exp"
                run_case "${T_CWD[$id]}" "$ans" "$TMP/act"
                if [[ -n $selftest ]]; then
                    echo "  ${D}$id ran:${N} ${T_REF[$id]}"
                    sed 's/^/      | /' "$TMP/exp.out" | head -n 12
                    [[ -s $TMP/exp.err ]] && sed 's/^/      ! /' "$TMP/exp.err" | head -n 5
                    continue
                fi
                if compare_runs "$TMP/exp" "$TMP/act" "${T_CMP[$id]}" >"$TMP/why"; then
                    echo "${G}  ✔ $id${N}  $ans"
                    pass=$((pass + 1))
                else
                    echo "${R}  ✘ $id${N}  $ans"
                    cat "$TMP/why"
                fi
                ;;
            script)
                if [[ -n $selftest ]]; then
                    src="$DRILLS_DIR/solutions/day$DAY/${T_FILE[$id]}"
                else
                    src="$(scripts_dir)/${T_FILE[$id]}"
                fi
                if [[ ! -f $src ]]; then
                    echo "${Y}  ? $id${N} no script yet (expected $src)"
                    continue
                fi
                local sol="$DRILLS_DIR/solutions/day$DAY/${T_FILE[$id]}"
                IFS=$'\x1e' read -rd '' -a runs <<<"${T_RUNS[$id]}"
                local n=0 good=0 r
                : >"$TMP/why"
                for r in "${runs[@]}"; do
                    [[ -z ${r//[$'\n ']/} ]] && continue
                    n=$((n + 1))
                    run_case "${T_CWD[$id]}" "$r" "$TMP/exp" "${T_FILE[$id]}" "$sol"
                    if [[ -n $selftest ]]; then
                        echo "  ${D}$id test $n:${N} $r   ${D}(exit $(cat "$TMP/exp.status"))${N}"
                        sed 's/^/      | /' "$TMP/exp.out" | head -n 12
                        [[ -s $TMP/exp.err ]] && sed 's/^/      ! /' "$TMP/exp.err" | head -n 5
                        continue
                    fi
                    run_case "${T_CWD[$id]}" "$r" "$TMP/act" "${T_FILE[$id]}" "$src"
                    if compare_runs "$TMP/exp" "$TMP/act" "${T_CMP[$id]}" >>"$TMP/why.$n"; then
                        good=$((good + 1))
                    else
                        { echo "    test: $r"; cat "$TMP/why.$n"; } >>"$TMP/why"
                    fi
                    rm -f "$TMP/why.$n"
                done
                [[ -n $selftest ]] && continue
                if ((good == n)); then
                    echo "${G}  ✔ $id${N}  ${T_FILE[$id]} passed $good/$n tests"
                    pass=$((pass + 1))
                else
                    echo "${R}  ✘ $id${N}  ${T_FILE[$id]} passed $good/$n tests"
                    head -n 40 "$TMP/why"
                fi
                ;;
            text)
                if [[ -n $selftest ]]; then
                    local acc=${T_ACCEPT[$id]%$'\x1e'}
                    echo "  ${D}$id accepts:${N} ${acc//$'\x1e'/  |  }"
                    continue
                fi
                ans=$(get_answer "$id")
                if [[ -z $ans ]]; then
                    echo "${Y}  ? $id${N} no answer yet"
                    continue
                fi
                ok=0
                local norm a
                norm=$(echo "$ans" | tr -s ' \t' '  ' | sed 's/^ *//; s/ *$//')
                IFS=$'\x1e' read -rd '' -a accs <<<"${T_ACCEPT[$id]}"
                for a in "${accs[@]}"; do
                    [[ -z ${a//[$'\n ']/} ]] && continue
                    [[ $norm == "$a" ]] && ok=1
                done
                if ((ok)); then
                    echo "${G}  ✔ $id${N}  $ans"
                    pass=$((pass + 1))
                else
                    echo "${R}  ✘ $id${N}  $ans"
                    echo "      ${Y}not one of the accepted answers.${N} Check the app's answer for this topic,"
                    echo "      or run ./drill.sh check $DAY $id --reveal to see them."
                    [[ ${3:-} == --reveal ]] && echo "      accepted: ${T_ACCEPT[$id]//$'\x1e'/  |  }"
                fi
                ;;
        esac
    done
    if [[ -z $selftest ]]; then
        echo
        echo "${B}Score: $pass / $total${N}"
        mkdir -p "$WORK_ROOT/results"
        echo "$(date '+%F %R') day $DAY: $pass/$total" >>"$WORK_ROOT/results/history.txt"
        echo "${D}(saved to $WORK_ROOT/results/history.txt; enter it in the app's Today checklist)${N}"
    fi
}

main() {
    local cmd=${1:-help}
    case $cmd in
        list) cmd_list ;;
        show) load_day "${2:-}"; cmd_show ;;
        start) load_day "${2:-}"; cmd_start ;;
        sandbox) load_day "${2:-}"; local p; p=$(make_play); echo "Fresh sandbox: $p"
                 echo "Explore it with:   cd ${p/#$HOME/\~}" ;;
        check)
            load_day "${2:-}"
            if [[ ${3:-} == --reveal ]]; then cmd_check "" "" --reveal
            else cmd_check "${3:-}" "" "${4:-}"; fi ;;
        selftest) load_day "${2:-}"; cmd_check "${3:-}" yes ;;
        *) sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//' ;;
    esac
}

main "$@"
