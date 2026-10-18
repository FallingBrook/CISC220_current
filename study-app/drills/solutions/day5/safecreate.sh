#!/bin/bash

# safecreate.sh: create a new executable script, never overwrite

if [[ $# -ne 1 ]]; then
    echo "safecreate.sh: filename required" >&2
    exit 2
fi

if [[ -e $1 ]]; then
    echo "safecreate.sh: $1 already exists" >&2
    exit 1
fi

echo '#!/bin/bash' > "$1"
chmod u+x "$1"
