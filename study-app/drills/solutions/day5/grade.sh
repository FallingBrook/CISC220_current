#!/bin/bash

# grade.sh: convert a mark to a letter grade

if (( $# != 1 )); then
    echo "Usage: grade.sh mark" >&2
    exit 1
fi

mark=$1
if [[ ! $mark =~ ^[0-9]+$ ]] || (( mark > 100 )); then
    echo "grade.sh: mark must be an integer from 0 to 100" >&2
    exit 2
fi

if (( mark >= 80 )); then
    echo A
elif (( mark >= 70 )); then
    echo B
elif (( mark >= 60 )); then
    echo C
elif (( mark >= 50 )); then
    echo D
else
    echo F
fi
