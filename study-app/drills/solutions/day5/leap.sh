#!/bin/bash

# leap.sh: is a year a leap year?

if (( $# != 1 )); then
    echo "Usage: leap.sh year" >&2
    exit 1
fi

yr=$1
if [[ ! $yr =~ ^[0-9]+$ ]]; then
    echo "leap.sh: $yr is not a year" >&2
    exit 2
fi

if (( yr % 400 == 0 || (yr % 4 == 0 && yr % 100 != 0) )); then
    echo "$yr is a leap year"
else
    echo "$yr is not a leap year"
fi
