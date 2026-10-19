#!/bin/bash

# tr220.sh SEQ1 SEQ2 STR   translates the characters of STR that are in SEQ1
# into the characters at the same index in SEQ2 (Assignment 3 Q5)

# hasdups STR
# prints "c:i = c:j" for the first character of STR that is repeated
# (i is its first index, j the index of its next copy) and returns 0;
# prints nothing and returns 1 if STR has no repeated characters
hasdups() {
    local s=$1
    local n=${#s}
    local i j
    for (( i = 0; i < n; i++ )); do
        for (( j = i + 1; j < n; j++ )); do
            if [[ ${s:i:1} == "${s:j:1}" ]]; then
                echo "${s:i:1}:$i = ${s:j:1}:$j"
                return 0
            fi
        done
    done
    return 1
}

# indexof CH STR
# prints the index of the first CH in STR and returns 0;
# prints -1 and returns 1 if CH is not in STR
indexof() {
    local ch=$1
    local str=$2
    local i
    for (( i = 0; i < ${#str}; i++ )); do
        if [[ ${str:i:1} == "$ch" ]]; then
            echo "$i"
            return 0
        fi
    done
    echo -1
    return 1
}

if (( $# != 3 )); then
    echo "Usage: tr220.sh seq1 seq2 str" >&2
    exit 1
fi
seq1=$1
seq2=$2
str=$3
if (( ${#seq1} > ${#seq2} )); then
    echo "tr220.sh: seq1 length > seq2 length" >&2
    exit 2
fi
if hasdups "$seq1" > /dev/null; then
    echo "tr220.sh: seq1 has duplicated characters" >&2
    exit 3
fi

result=""
for (( k = 0; k < ${#str}; k++ )); do
    c=${str:k:1}
    if i=$(indexof "$c" "$seq1"); then
        result=$result${seq2:i:1}
    else
        result=$result$c
    fi
done
echo "$result"
