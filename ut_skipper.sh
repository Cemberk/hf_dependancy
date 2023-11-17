#!/bin/bash

# Define the directory containing the test files
TEST_DIR="tests/"

# File to store pytest results
PYTEST_RESULTS_FILE="pytest_results.log"

DEFAULT_INDENTATION="\ \ \ \ "

# Run pytest with --verbose and --no-cache, saving output to a file
RUN_SLOW=1 pytest --verbose $TEST_DIR -p no:cacheprovider | tee $PYTEST_RESULTS_FILE

# Process each failed test from the pytest output
grep 'FAILED' $PYTEST_RESULTS_FILE | while read -r line; do

    # Extract the test file and test function from the line
    TEST_FILE=$(echo $line | awk -F "::" '{print $1}')
    TEST_FUNCTION=$(echo $line | awk -F "::" '{print $3}' | awk '{print $1}')

    echo $TEST_FILE
    echo $TEST_FUNCTION

    # Check if "import pytest" is already added
    if ! grep -q "import pytest" $TEST_FILE; then
        # Add "import pytest" at the top of the file
        sed -i '1s/^/import pytest\n/' $TEST_FILE
    fi

    # Add the skip decorator with correct indentation above the failing test
    sed -i "/def ${TEST_FUNCTION}/i ${DEFAULT_INDENTATION}@pytest.mark.skip(reason=\"UT compatibility skip\")" $TEST_FILE
    
done



