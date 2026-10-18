#!/bin/bash

# checkuser.sh: check that a username follows the rules

if (( $# == 0 )); then
    echo "Usage: checkuser.sh username" >&2
    exit 1
fi

user=$1
status=0

if [[ $user =~ [[:space:]] ]]; then
    echo "username cannot contain whitespace" >&2
    status=2
fi

if (( ${#user} < 3 || ${#user} > 12 )); then
    echo "username length must be from 3 to 12" >&2
    status=2
fi

if [[ ! $user =~ ^[a-z] ]]; then
    echo "username must start with a lowercase letter" >&2
    status=2
fi

if [[ $user =~ [[:upper:]] ]]; then
    echo "username cannot contain uppercase letters" >&2
    status=2
fi

if [[ ! $user =~ [[:digit:]] ]]; then
    echo "username must contain at least one digit" >&2
    status=2
fi

exit $status
