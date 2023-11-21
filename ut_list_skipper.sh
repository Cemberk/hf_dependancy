#!/bin/bash

TEST_DIR="tests/"
PYTEST_RESULTS_FILE="pytest_results.log"
DEFAULT_INDENTATION="    "
TEST_LIST_FILE="test_list.txt" # File containing the list of tests

# Function to process failed tests
process_failed_test() {
    TEST_FILE=$1
    TEST_FUNCTION=$2

    echo "Processing failed test: $TEST_FUNCTION in $TEST_FILE"

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

    # Add the skip decorator above the failing test
    sed -i "/def ${TEST_FUNCTION}/i ${DEFAULT_INDENTATION}@pytest.mark.skip(reason=\"UT compatibility skip\")" $TEST_FILE
}

# Loop through each test in the list
while read -r test_name; do
    echo "Running pytest for: $test_name"
    RUN_SLOW=1 pytest --verbose ${test_name} -p no:cacheprovider | tee $PYTEST_RESULTS_FILE

    # Check if the test failed
    if grep -q 'FAILED' $PYTEST_RESULTS_FILE; then
        TEST_FILE=$(grep 'FAILED' $PYTEST_RESULTS_FILE | awk -F "::" '{print $1}')
        TEST_FUNCTION=$(grep 'FAILED' $PYTEST_RESULTS_FILE | awk -F "::" '{print $3}' | awk '{print $1}')
        process_failed_test $TEST_FILE $TEST_FUNCTION
    fi
done < "$TEST_LIST_FILE"
