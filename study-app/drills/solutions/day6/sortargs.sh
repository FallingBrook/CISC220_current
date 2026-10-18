#!/bin/bash

# sortargs.sh INT...   prints the arguments sorted in ascending order using selection sort

# minidx START: sets idx to the index of the smallest element of arr from START to the end
minidx() {
    local i
    idx=$1
    for (( i = $1 + 1; i < n; i++ )); do
        if (( arr[i] < arr[idx] )); then
            idx=$i
        fi
    done
}

sort() {
    local j tmp
    n=${#arr[@]}
    for (( j = 0; j < n; j++ )); do
        minidx "$j"
        tmp=${arr[j]}
        arr[j]=${arr[idx]}
        arr[idx]=$tmp
    done
}

arr=("$@")
sort
echo "${arr[@]}"
