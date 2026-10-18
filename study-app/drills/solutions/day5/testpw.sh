#!/bin/bash

# testpw.sh: is a password strong?

if (( $# == 0 )); then
    echo "Usage: testpw.sh password" >&2
    exit 1
fi

pw=$1
status=0

if [[ $pw =~ [[:space:]] ]]; then
    echo "password cannot contain whitespace" >&2
    status=2
fi

if (( ${#pw} < 8 )); then
    echo "password length less than 8" >&2
    status=2
fi

if [[ ! $pw =~ [[:alpha:]] ]]; then
    echo "password must contain at least one letter" >&2
    status=2
fi

if [[ ! $pw =~ [[:digit:]] ]]; then
    echo "password must contain at least one digit" >&2
    status=2
fi

if [[ ! $pw =~ [[:punct:]] ]]; then
    echo "password must contain at least one symbol" >&2
    status=2
fi

exit $status
