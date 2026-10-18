#!/bin/bash

# hello2.sh: greet $1, or the world if $1 is missing or empty

name=${1:-world}
echo "Hello, $name!"
