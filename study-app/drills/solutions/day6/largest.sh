#!/bin/bash

# largest.sh INT...   prints the largest integer argument

# max INT... : prints the largest of its arguments
max() {
    local hi=$1
    local x
    for x in "$@"; do
        if (( x > hi )); then
            hi=$x
        fi
    done
    echo "$hi"
}

if (( $# == 0 )); then
    echo "Usage: largest.sh int..." >&2
    exit 1
fi
result=$(max "$@")
echo "largest: $result"
