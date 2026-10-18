#!/bin/bash

sum=0
for n in "$@"; do
    (( sum += n ))
done
echo "$sum"
