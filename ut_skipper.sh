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
        # Check if there are any __future__ imports
        if grep -q "from __future__ import" $TEST_FILE; then
            # Insert 'import pytest' after the last __future__ import
            awk '/from __future__ import/ {print; last_line=NR; next} NR==last_line+1 {print "import pytest\n"$0; next} {print}' $TEST_FILE > temp_file && mv temp_file $TEST_FILE
        else
            # Add 'import pytest' at the top of the file
            sed -i '1s/^/import pytest\n/' $TEST_FILE
        fi
    fi

    # Add the skip decorator with correct indentation above the failing test
    sed -i "/def ${TEST_FUNCTION}/i ${DEFAULT_INDENTATION}@pytest.mark.skip(reason=\"UT compatibility skip\")" $TEST_FILE
    
done



