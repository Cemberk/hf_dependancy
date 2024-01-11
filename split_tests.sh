#!/bin/bash

# Check if the number of chunks is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number-of-chunks>"
    exit 1
fi

NUM_CHUNKS=$1
TESTS_DIR="tests/"
EXAMPLES_DIR="examples/"

# Find all test files
TEST_FILES=$(find "$TESTS_DIR" "$EXAMPLES_DIR" -name 'test_*.py')
TOTAL_FILES=$(echo "$TEST_FILES" | wc -w)

# Calculate the number of tests per chunk
TESTS_PER_CHUNK=$((TOTAL_FILES / NUM_CHUNKS))
REMAINDER=$((TOTAL_FILES % NUM_CHUNKS))

if [ "$REMAINDER" -ne 0 ]; then
    TESTS_PER_CHUNK=$((TESTS_PER_CHUNK + 1))
fi

# Function to output pytest command for a chunk
output_pytest_command() {
    local start=$1
    local end=$2
    local chunk_files=$(echo "$TEST_FILES" | sed -n "${start},${end}p" | tr '\n' ' ')
    echo "pytest $chunk_files -p no:cacheprovider -p no:faulthandler"
}

# Loop through each chunk and echo the pytest command
for (( i=1; i<=NUM_CHUNKS; i++ )); do
    START_INDEX=$(((i - 1) * TESTS_PER_CHUNK + 1))
    END_INDEX=$((i * TESTS_PER_CHUNK))

    if [ "$i" -eq "$NUM_CHUNKS" ] && [ "$REMAINDER" -ne 0 ]; then
        END_INDEX=$((START_INDEX + REMAINDER - 1))
    fi

    output_pytest_command $START_INDEX $END_INDEX
done
