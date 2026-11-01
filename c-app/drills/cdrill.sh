#!/usr/bin/env bash
#
# cdrill.sh -- C labs and the Assignment 4 checker for the CISC220 C study app
#
# Usage:
#   ./cdrill.sh list              list the lab days
#   ./cdrill.sh start N           show day N's tasks and create ~/cisc220_c/dayN/ for your programs
#   ./cdrill.sh show N            show day N's tasks again
#   ./cdrill.sh check N [ID]      compile and test your programs for day N (or only task ID)
#   ./cdrill.sh a4 [DIR] [FILE]   test your Assignment 4 files (default DIR: ~/CISC220_A4)
#   ./cdrill.sh selftest N        (for maintainers) run the reference solutions
#
# Your programs live in ~/cisc220_c/dayN/ (override with CISC220_C_HOME). Each test compiles your program with
# gcc -std=c17 -Wall, runs it with the test's command line arguments, and compares what it prints and its
# exit status with the reference program's. Different code that behaves the same passes.

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${CISC220_C_HOME:-$HOME/cisc220_c}"
TMP="$WORK/.grading"
CFLAGS=(-std=c17 -Wall)

if [[ -t 1 ]]; then B=$'\e[1m'; G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; D=$'\e[2m'; N=$'\e[0m'
else B=; G=; R=; Y=; D=; N=; fi

# ---------------------------------------------------------------- task definitions (days/dayN.sh)
declare -a T_IDS=()
declare -A T_FILE=() T_PROMPT=() T_RUNS=() T_CMP=() T_LIBS=()
CUR=""
DAY_TITLE=""
ctask()   { CUR=$1; T_IDS+=("$1"); T_FILE[$1]=$2; T_PROMPT[$1]=$3; T_RUNS[$1]=""; T_CMP[$1]=out,err,status; T_LIBS[$1]=""; }
crun()    { T_RUNS[$CUR]+="$1"$'\x1e'; }
compare() { T_CMP[$CUR]=$1; }
libs()    { T_LIBS[$CUR]=$1; }

die() { echo "${R}error:${N} $*" >&2; exit 1; }
load_day() {
    DAY=$1
    [[ $DAY =~ ^[0-9]+$ ]] || die "day must be a number, e.g. ./cdrill.sh start 1"
    [[ -f $DIR/days/day$DAY.sh ]] || die "no labs for day $DAY (try ./cdrill.sh list)"
    # shellcheck source=/dev/null
    source "$DIR/days/day$DAY.sh"
}

# compile SRC OUT LIBS -> prints compiler messages to $TMP/cc.txt; returns gcc's status
compile() {
    local libs=()
    [[ -n ${3:-} ]] && read -ra libs <<<"$3"
    gcc "${CFLAGS[@]}" -o "$2" "$1" "${libs[@]}" >"$TMP/cc.txt" 2>&1
}

# run PROG ARGS PREFIX: runs with the args (shell words), saving .out .err .status
run_prog() {
    local prog=$1 args=$2 pre=$3
    (
        cd "$TMP" || exit
        eval "set -- $args"
        timeout 5 "$prog" "$@" >"$pre.out" 2>"$pre.err" </dev/null
        echo $? >"$pre.status"
    )
}

same() { # EXP ACT PARTS -> prints the first difference, returns 1 if different
    local p label
    IFS=, read -ra parts <<<"$3"
    for p in "${parts[@]}"; do
        case $p in out) label="standard output" ;; err) label="standard error" ;; status) label="exit status" ;; *) continue ;; esac
        if [[ $p == err ]]; then
            # stderr messages may be worded differently; only require that both are empty or both are not
            if { [[ -s $1.err ]] && [[ ! -s $2.err ]]; } || { [[ ! -s $1.err ]] && [[ -s $2.err ]]; }; then
                echo "      ${Y}$label differs${N}: expected $( [[ -s $1.err ]] && echo "an error message" || echo "nothing" ), got $( [[ -s $2.err ]] && echo "\"$(head -c 80 "$2.err")\"" || echo "nothing" )"
                return 1
            fi
            continue
        fi
        if ! cmp -s "$1.$p" "$2.$p"; then
            echo "      ${Y}$label differs${N} (${R}-expected${N} ${G}+yours${N}):"
            diff -u "$1.$p" "$2.$p" | tail -n +4 | head -n 12 | sed 's/^/        /'
            return 1
        fi
    done
}

print_task() {
    echo "${B}[$1]${N} ${D}(write $WORK/day$DAY/${T_FILE[$1]})${N}"
    printf '%s\n' "${T_PROMPT[$1]}" | fold -s -w 92 | sed 's/^/    /'
    [[ -n ${T_LIBS[$1]} ]] && echo "    ${D}compile with: gcc -std=c17 -Wall -o prog ${T_FILE[$1]} ${T_LIBS[$1]}${N}"
    echo
}

cmd_list() {
    local f n
    for f in "$DIR"/days/day*.sh; do
        n=${f##*/day}; n=${n%.sh}
        ( source "$f"; printf '  day %-3s %s (%d tasks)\n' "$n" "$DAY_TITLE" "${#T_IDS[@]}" )
    done | sort -n -k2
    echo "  a4      Assignment 4 checker (./cdrill.sh a4)"
}

cmd_start() {
    mkdir -p "$WORK/day$DAY"
    echo "${B}Day $DAY labs: $DAY_TITLE${N}"; echo
    local id; for id in "${T_IDS[@]}"; do print_task "$id"; done
    echo "Write your programs in:  ${B}${WORK/#$HOME/\~}/day$DAY/${N}   (e.g. nano ${WORK/#$HOME/\~}/day$DAY/${T_FILE[${T_IDS[0]}]})"
    echo "Test them with:          ./cdrill.sh check $DAY"
}

cmd_check() {
    local only=${1:-} selftest=${2:-} id pass=0 total=0
    mkdir -p "$TMP"
    echo "${B}Day $DAY labs: $DAY_TITLE${N}"
    for id in "${T_IDS[@]}"; do
        [[ -n $only && $id != "$only" ]] && continue
        total=$((total + 1))
        local f=${T_FILE[$id]} ref="$DIR/solutions/day$DAY/${T_FILE[$id]}" mine="$WORK/day$DAY/${T_FILE[$id]}"
        [[ -n $selftest ]] && mine=$ref
        if [[ ! -f $mine ]]; then echo "${Y}  ? $id${N} no program yet (expected $mine)"; continue; fi
        compile "$ref" "$TMP/ref" "${T_LIBS[$id]}" || { echo "${R}  ! $id reference does not compile${N}"; cat "$TMP/cc.txt"; continue; }
        if ! compile "$mine" "$TMP/mine" "${T_LIBS[$id]}"; then
            echo "${R}  ✘ $id${N}  $f does not compile:"; sed 's/^/      /' "$TMP/cc.txt" | head -n 15; continue
        fi
        [[ -s $TMP/cc.txt && -z $selftest ]] && { echo "  ${Y}warnings for $f (fix these, they are usually bugs):${N}"; sed 's/^/      /' "$TMP/cc.txt" | head -n 8; }
        IFS=$'\x1e' read -rd '' -a runs <<<"${T_RUNS[$id]}"
        local n=0 good=0 r why=""
        for r in "${runs[@]}"; do
            [[ $r == $'\n' ]] && continue
            n=$((n + 1))
            run_prog "$TMP/ref" "$r" "$TMP/exp"
            if [[ -n $selftest ]]; then
                echo "  ${D}$id test $n:${N} ./${f%.c} $r   ${D}(exit $(cat "$TMP/exp.status"))${N}"
                sed 's/^/      | /' "$TMP/exp.out" | head -n 8; [[ -s $TMP/exp.err ]] && sed 's/^/      ! /' "$TMP/exp.err" | head -n 3
                continue
            fi
            run_prog "$TMP/mine" "$r" "$TMP/act"
            if out=$(same "$TMP/exp" "$TMP/act" "${T_CMP[$id]}"); then good=$((good + 1))
            else why+="    test: ./${f%.c} $r"$'\n'"$out"$'\n'; fi
        done
        [[ -n $selftest ]] && continue
        if ((good == n)); then echo "${G}  ✔ $id${N}  $f passed $good/$n tests"; pass=$((pass + 1))
        else echo "${R}  ✘ $id${N}  $f passed $good/$n tests"; printf '%s' "$why" | head -n 30; fi
    done
    [[ -z $selftest ]] && { echo; echo "${B}Score: $pass / $total${N}"; }
    return 0
}

# ---------------------------------------------------------------- Assignment 4
# Expected results come from the assignment's examples (plus a few extra cases), never from a solution file.
a4_cases() { # file|args|expected stdout (\n-escaped)|exit status|stderr expected (y/n)
cat <<'EOF'
concat2.c|||0|n
concat2.c|marsh|marsh\n|0|n
concat2.c|marsh mallow|marshmallow\n|0|n
concat2.c|"a b" c|a bc\n|0|n
concat2.c|"" xyz|xyz\n|0|n
concat2.c|hello ""|hello\n|0|n
sin.c|||1|y
sin.c|1 2||1|y
sin.c|0|     0.00000000000000000\n|0|n
sin.c|-0.01|    -0.00999983333416666\n|0|n
sin.c|0.5|     0.47942553860420301\n|0|n
sin.c|0.8|     0.71735609089954966\n|0|n
sin.c|abc|     0.00000000000000000\n|0|n
sin.c|1|     0.84147098480865845\n|0|n
sumones.c|||0|n
sumones.c|00000000||0|n
sumones.c|00000000 00000001|00000001\n|0|n
sumones.c|00000001 00000001|00000010\n|0|n
sumones.c|00001100 01100011|01101111\n|0|n
sumones.c|01001001 11000000|00001010\n|0|n
sumones.c|10000000 11111110|01111111\n|0|n
sumones.c|01111111 00000001|10000000\n|0|n
sumones.c|11111111 11111111|11111111\n|0|n
sumones.c|11111111 00000000|11111111\n|0|n
EOF
}
# Functions each program may call (concat2 has a restriction; the others are listed for the warning check only).
a4_allowed() {
    case $1 in
        concat2.c) echo "main strlen printf puts" ;;
        *) echo "" ;;
    esac
}

cmd_a4() {
    local adir=${1:-$HOME/CISC220_A4} onlyf=${2:-} file args exp status errx pass=0 total=0 last=""
    adir=${adir%/}
    mkdir -p "$TMP"
    echo "${B}Assignment 4 checker${N} ${D}($adir)${N}"
    while IFS='|' read -r file args exp status errx; do
        [[ -n $onlyf && $file != "$onlyf" ]] && continue
        if [[ $file != "$last" ]]; then
            last=$file
            echo; echo "${B}$file${N}"
            if [[ ! -f $adir/$file ]]; then echo "${Y}  ? not found: $adir/$file${N}"; skip=1; continue; fi
            skip=0
            local libs=""; [[ $file != concat2.c ]] && libs="-lm"
            if ! compile "$adir/$file" "$TMP/a4prog" "$libs"; then
                echo "${R}  ✘ does not compile:${N}"; sed 's/^/      /' "$TMP/cc.txt" | head -n 15; skip=1; continue
            fi
            [[ -s $TMP/cc.txt ]] && { echo "  ${Y}compiler warnings (fix them; they are often real bugs):${N}"; sed 's/^/      /' "$TMP/cc.txt" | head -n 8; }
            local allowed; allowed=$(a4_allowed "$file")
            if [[ -n $allowed ]]; then
                local calls bad=""
                calls=$(sed -e 's://.*$::' "$adir/$file" | grep -oE '\b[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(' | tr -d ' (' | sort -u)
                for c in $calls; do
                    case " $allowed if for while switch return sizeof " in *" $c "*) ;; *) bad+=" $c" ;; esac
                done
                [[ -n $bad ]] && echo "  ${R}restriction:${N} calls functions that are not allowed here:${bad} (only strlen, printf and puts)"
            fi
        fi
        [[ ${skip:-0} == 1 ]] && continue
        total=$((total + 1))
        run_prog "$TMP/a4prog" "$args" "$TMP/a4"
        printf '%b' "$exp" >"$TMP/a4exp.out"
        local ok=1 msg=""
        if ! cmp -s "$TMP/a4exp.out" "$TMP/a4.out"; then
            ok=0
            if [[ "$(cat "$TMP/a4exp.out")" == "$(cat "$TMP/a4.out")" ]]; then
                msg+="      stdout: right text, but the newline at the end is missing or extra (puts adds one; printf needs \\n)"$'\n'
            else
                msg+="      stdout: expected $(printf '%q' "$(cat "$TMP/a4exp.out")"), got $(printf '%q' "$(cat "$TMP/a4.out")")"$'\n'
            fi
        fi
        [[ $(cat "$TMP/a4.status") == "$status" ]] || { ok=0; msg+="      exit status: expected $status, got $(cat "$TMP/a4.status")"$'\n'; }
        if [[ $errx == y && ! -s $TMP/a4.err ]]; then ok=0; msg+="      expected an error message on standard error (fprintf(stderr, ...))"$'\n'; fi
        if [[ $errx == n && -s $TMP/a4.err ]]; then ok=0; msg+="      unexpected output on standard error: $(head -c 80 "$TMP/a4.err")"$'\n'; fi
        if ((ok)); then echo "${G}  ✔${N} ./${file%.c} $args"; pass=$((pass + 1))
        else echo "${R}  ✘${N} ./${file%.c} $args"; printf '%s' "$msg"; fi
    done < <(a4_cases)
    echo; echo "${B}Passed $pass / $total tests${N}"
    echo "${D}These tests cover the assignment's examples and a few edge cases; the TAs may test more.${N}"
}

case ${1:-help} in
    list) cmd_list ;;
    start) load_day "${2:-}"; cmd_start ;;
    show) load_day "${2:-}"; echo "${B}Day $DAY labs: $DAY_TITLE${N}"; echo; for id in "${T_IDS[@]}"; do print_task "$id"; done ;;
    check) load_day "${2:-}"; cmd_check "${3:-}" ;;
    selftest) load_day "${2:-}"; cmd_check "${3:-}" yes ;;
    a4) cmd_a4 "${2:-}" "${3:-}" ;;
    *) sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
