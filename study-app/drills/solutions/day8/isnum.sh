#!/bin/bash

s=$1
if [[ $s =~ ^[0-9]+$ ]]; then
    echo "$s is a number"
else
    echo "$s is not a number" >&2
fi
