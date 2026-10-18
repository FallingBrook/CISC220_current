#!/bin/bash

# calc.sh: integer arithmetic on two numbers

if (( $# != 2 )); then
    echo "Usage: calc.sh a b" >&2
    exit 1
fi

a=$1
b=$2
echo "$a + $b = $(( a + b ))"
echo "$a - $b = $(( a - b ))"
echo "$a * $b = $(( a * b ))"
echo "$a / $b = $(( a / b ))"
echo "$a % $b = $(( a % b ))"
