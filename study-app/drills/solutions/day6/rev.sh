#!/bin/bash

# rev.sh ARG...   prints the arguments in reverse order, one per line

arr=("$@")
for (( i = ${#arr[@]} - 1; i >= 0; i-- )); do
    echo "${arr[i]}"
done
