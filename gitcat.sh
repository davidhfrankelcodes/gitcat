#!/bin/bash

# gitcat.sh: Dump code from a git repo with guardrails and options

set -e

# Emojis for binary files
BIN_EMOJI="📦"
DEL_EMOJI="❌"

# Default ignore files
GITIGNORE=".gitignore"
GITCATIGNORE=".gitcatignore"

# Default max depth
MAX_DEPTH=999

# Usage function
usage() {
    echo "Usage: gitcat.sh [options] > output.txt"
    echo "Options:"
    echo "  -b        Force catting of binary files"
    echo "  -d <num>  Maximum directory depth (default: unlimited)"
    echo "  tree      Display file tree instead of catting"
    exit 1
}

# Check for git repository
if git rev-parse --is-inside-work-tree &>/dev/null; then
    IS_GIT_REPO=true
else
    IS_GIT_REPO=false
fi

# Collect ignore patterns
IGNORE_PATTERNS=()
if [ "$IS_GIT_REPO" = true ] && [ -f "$GITIGNORE" ]; then
    while read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        IGNORE_PATTERNS+=("$line")
    done < "$GITIGNORE"
fi

if [ "$IS_GIT_REPO" = true ] && [ -f "$GITCATIGNORE" ]; then
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

# Function to print file tree
print_tree() {
    find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}

# Parse arguments
FORCE_BINARY=false
MODE="cat"

while getopts "bd:" opt; do
    case $opt in
        b)
            FORCE_BINARY=true
            ;;
        d)
            MAX_DEPTH="$OPTARG"
            ;;
        \?)
            usage
            ;;
    esac
done
shift $((OPTIND -1))

if [ "$1" = "tree" ]; then
    MODE="tree"
fi

# List all files
if [ "$IS_GIT_REPO" = true ]; then
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
else
    # If not a git repo, just find all files
    FILES=($(find . -type f -maxdepth "$MAX_DEPTH"))
fi

# Main loop
if [ "$MODE" = "cat" ]; then
    for file in "${FILES[@]}"; do
        # Remove leading ./ if present
        file="${file#./}"

        should_ignore "$file" && continue

        if [ "$IS_GIT_REPO" = true ] && git ls-files --deleted --error-unmatch "$file" &>/dev/null; then
            echo "$DEL_EMOJI Deleted: $file"
            continue
        fi

        if [ ! -f "$file" ]; then
            continue
        fi

        # Check depth
        depth=$(echo "$file" | tr -d -c / | wc -c)
        if (( depth > MAX_DEPTH )); then
            continue
        fi

        # Check if binary
        if [ "$FORCE_BINARY" = true ] || ( grep -Iq . "$file" && [ -s "$file" ] ); then
            echo "===== $file ====="
            cat "$file"
            echo
        else
            echo "$BIN_EMOJI Binary file: $file"
        fi
    done
elif [ "$MODE" = "tree" ]; then
    print_tree
fi