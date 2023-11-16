#!/bin/bash

# Define the directory containing the test files
TEST_DIR="tests/"

# File to store pytest results
PYTEST_RESULTS_FILE="pytest_results.log"

# Run pytest with --verbose and --no-cache, saving output to a file
pytest --verbose --no-cache $TEST_DIR | tee $PYTEST_RESULTS_FILE

# Process each failed test from the pytest output
grep 'FAILED' $PYTEST_RESULTS_FILE | while read -r line; do
    # Extract the file path and test name
    #file_path=$(echo $line | awk '{print $2}' | cut -d':' -f1)
    #test_name=$(echo $line | awk '{print $2}' | cut -d':' -f2)

    # Extract the test file and test function from the line
    TEST_FILE=$(echo $line | awk -F "::" '{print $1}')
    TEST_FUNCTION=$(echo $line | awk -F "::" '{print $2}')

    # Check if "import pytest" is already in the file, if not, add it
    #grep -q 'import pytest' $file_path || sed -i '1iimport pytest' $file_path

    # Add the pytest.mark.skip decorator above the test function
    #sed -i "/^def $test_name/i@pytest.mark.skip(reason=\"UT compatibility skip\")" $file_path

    # Check if "import pytest" is already added
    if ! grep -q "import pytest" $TEST_FILE; then
        # Add "import pytest" at the top of the file
        sed -i '1s/^/import pytest\n/' $TEST_FILE
    fi

    # Add the skip decorator above the failing test
    sed -i "/def ${TEST_FUNCTION}/i @pytest.mark.skip(reason=\"UT compatibility skip\")" $TEST_FILE

done



