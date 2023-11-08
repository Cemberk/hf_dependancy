#!/bin/bash

# File to store the execution time
TIME_FILE="time_output.txt"

# The workload command
WORKLOAD_COMMAND="RUN_SLOW=1 pytest tests/ 2>&1 | tee all_test.log"

# Function to execute the workload and capture the time
run_and_capture_time() {
    # Use the time command and redirect the stderr to stdout to capture the time output
    { time $WORKLOAD_COMMAND ; } 2>&1 | grep real | awk '{print $2}' > $TIME_FILE
}

# Export the TIME_FILE variable so it's available in the subshell
export TIME_FILE

# Export the WORKLOAD_COMMAND variable so it's available in the subshell
export WORKLOAD_COMMAND

# Run the workload in the background and capture the time
run_and_capture_time &

echo "Workload started in the background..."
