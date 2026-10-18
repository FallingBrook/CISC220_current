# countchar.sh: defines the function count_char (sourced, no shebang needed)

# count_char ch str
# prints the number of times the character ch appears in str;
# returns 0 if ch appears at least once, 1 otherwise
count_char() {
    local ch=$1
    local str=$2
    local count=0
    local i
    for (( i = 0; i < ${#str}; i++ )); do
        if [[ ${str:i:1} == "$ch" ]]; then
            (( count++ ))
        fi
    done
    echo "$count"
    if (( count > 0 )); then
        return 0
    else
        return 1
    fi
}
