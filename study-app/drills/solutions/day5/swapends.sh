#!/bin/bash

# swapends.sh: print the arguments with the first and last swapped

if (( $# < 2 )); then
    echo "Usage: swapends.sh arg1 arg2 ..." >&2
    exit 1
fi

arr=("$@")
last=$(( ${#arr[@]} - 1 ))
tmp=${arr[0]}
arr[0]=${arr[last]}
arr[last]=$tmp
echo "${arr[@]}"
