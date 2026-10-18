#!/bin/bash

# isint.sh: is the argument a signed or unsigned integer?

if (( $# != 1 )); then
    echo "Usage: isint.sh value" >&2
    exit 1
fi

if [[ $1 =~ ^[-+]?[0-9]+$ ]]; then
    echo "$1 is an integer"
else
    echo "$1 is not an integer"
    exit 2
fi
