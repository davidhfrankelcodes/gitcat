#!/bin/bash

# gitcat.sh: Dump code from a git repo with guardrails and options

set -e

# Emojis for binary files
BIN_EMOJI="📦"
DEL_EMOJI="❌"

# Default ignore files
GITIGNORE=".gitignore"
GITCATIGNORE=".gitcatignore"

# Collect ignore patterns
IGNORE_PATTERNS=()
if [ -f "$GITIGNORE" ]; then
    while read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        IGNORE_PATTERNS+=("$line")
    done < "$GITIGNORE"
fi
if [ -f "$GITCATIGNORE" ]; then
    while read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        IGNORE_PATTERNS+=("$line")
    done < "$GITCATIGNORE"
fi

# Check if file should be ignored
should_ignore() {
    local file="$1"
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$file" == $pattern || "$file" == ./$pattern ]]; then
            return 0
        fi
    done
    return 1
}

# List all files tracked by git, including deleted
mapfile -t FILES < <(git ls-files --deleted --others --exclude-standard --cached --stage | awk '{print $4}')

# Add all tracked files (including deleted)
mapfile -t TRACKED < <(git ls-files --stage | awk '{print $4}')
for f in "${TRACKED[@]}"; do
    if [[ ! " ${FILES[*]} " =~ " $f " ]]; then
        FILES+=("$f")
    fi
done

# Remove duplicates
FILES=($(printf "%s\n" "${FILES[@]}" | sort -u))

for file in "${FILES[@]}"; do
    should_ignore "$file" && continue

    if git ls-files --deleted --error-unmatch "$file" &>/dev/null; then
        echo "$DEL_EMOJI Deleted: $file"
        continue
    fi

    if [ ! -f "$file" ]; then
        continue
    fi

    # Check if binary
    if grep -Iq . "$file"; then
        echo "===== $file ====="
        cat "$file"
        echo
    else
        echo "$BIN_EMOJI Binary file: $file"
    fi
done