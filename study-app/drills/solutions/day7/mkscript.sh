#!/bin/bash

# mkscript.sh: create an empty, executable Bash script named NAME.sh

if (( $# != 1 )); then
    echo "Usage: mkscript.sh name" >&2
    exit 1
fi

file="$1.sh"
if [[ -e $file ]]; then
    echo "mkscript.sh: $file already exists" >&2
    exit 2
fi

echo '#!/bin/bash' > "$file"
chmod 700 "$file"
