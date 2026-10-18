#!/bin/bash

# halves.sh: print the first half and the second half of $1 on separate lines

s=$1
n=$(( ${#s} / 2 ))

echo "${s:0:n}"
echo "${s:n}"
