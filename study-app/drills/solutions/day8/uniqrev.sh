#!/bin/bash

# uniqrev.sh: prints the command line arguments in reverse order
# with duplicates removed

# returns 0 if $1 is an element of the array out, 1 otherwise
contains() {
    local elem
    for elem in "${out[@]}"; do
        if [[ $elem == "$1" ]]; then
            return 0
        fi
    done
    return 1
}

# copies the elements of arr into out, skipping repeated values
dedup() {
    out=()
    local elem
    for elem in "${arr[@]}"; do
        if ! contains "$elem"; then
            out+=("$elem")
        fi
    done
}

# reverses the order of the elements of out
reverse() {
    local n=${#out[@]}
    local i tmp
    for (( i = 0; i < n / 2; i++ )); do
        tmp=${out[i]}
        out[i]=${out[n - 1 - i]}
        out[n - 1 - i]=$tmp
    done
}

if (( $# == 0 )); then
    echo "Usage: uniqrev.sh value..." >&2
    exit 1
fi

arr=("$@")
dedup
reverse
echo "${out[@]}"
