# funcs.sh -- a file of functions; use it with:  source ./funcs.sh

# hasdups STR
# prints "c:i = c:j" for the first character of STR that is repeated
# (i is its first index, j the index of its next copy) and returns 0;
# prints nothing and returns 1 if STR has no repeated characters
hasdups() {
    local s=$1
    local n=${#s}
    local i j
    for (( i = 0; i < n; i++ )); do
        for (( j = i + 1; j < n; j++ )); do
            if [[ ${s:i:1} == "${s:j:1}" ]]; then
                echo "${s:i:1}:$i = ${s:j:1}:$j"
                return 0
            fi
        done
    done
    return 1
}

# indexof CH STR
# prints the index of the first CH in STR and returns 0;
# prints -1 and returns 1 if CH is not in STR
indexof() {
    local ch=$1
    local str=$2
    local i
    for (( i = 0; i < ${#str}; i++ )); do
        if [[ ${str:i:1} == "$ch" ]]; then
            echo "$i"
            return 0
        fi
    done
    echo -1
    return 1
}
