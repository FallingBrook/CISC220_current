#!/bin/bash

# extcount.sh EXT...   for each EXT prints "EXT: N", N = number of names in the cwd ending in .EXT

for ext in "$@"; do
    count=0
    for f in *."$ext"; do
        if [[ -e $f ]]; then
            (( count++ ))
        fi
    done
    echo "$ext: $count"
done
