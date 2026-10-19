#!/bin/bash

# isint.sh: is $1 a signed or unsigned integer?

[[ $1 =~ ^[-+]?[0-9]+$ ]] && echo "$1 is an integer"
[[ $1 =~ ^[-+]?[0-9]+$ ]] || echo "$1 is not an integer"
