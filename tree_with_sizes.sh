#!/bin/bash

# Function to display help/usage
usage() {
    echo "Usage: $0 [directory] [-d max-depth] [-h]"
    echo ""
    echo "Options:"
    echo "  directory       The directory to analyze (default: current directory)"
    echo "  -d max-depth    The maximum depth of subdirectories to display (default: 2)"
    echo "  -h              Show this help message"
    exit 0
}

# Default values
DIR="."
DEPTH=2

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) usage ;;
        -d) DEPTH=$2; shift ;;
        *) DIR=$1 ;;
    esac
    shift
done

# Check if the provided directory exists
if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Recursive function to generate the tree structure with sizes
print_tree_with_sizes() {
    local current_dir="$1"
    local prefix="$2"
    local depth="$3"
    local max_depth="$4"

    if [[ $depth -gt $max_depth ]]; then
        return
    fi

    # Get a sorted list of items in the current directory
    local items=("$current_dir"/* "$current_dir"/.[!.]* "$current_dir"/..?*)
    local total_items=${#items[@]}
    local counter=0

    for item in "${items[@]}"; do
        if [[ ! -e "$item" ]]; then
            continue
        fi

        counter=$((counter + 1))

        # Determine branch symbol
        local branch="├──"
        if [[ $counter -eq $total_items ]]; then
            branch="└──"
        fi

        # Get the size of the item
        local size
        size=$(du -sh "$item" 2>/dev/null | cut -f1)

        # Print the current item with size
        echo "${prefix}${branch} ${size} ${item#$DIR/}"

        # If the item is a directory, recursively process it
        if [[ -d "$item" ]]; then
            print_tree_with_sizes "$item" "${prefix}    " $((depth + 1)) "$max_depth"
        fi
    done
}

# Start printing the tree
print_tree_with_sizes "$DIR" "" 1 "$DEPTH"

