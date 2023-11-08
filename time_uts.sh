#!/bin/bash

echo "Workload started..."
mytime="$(time ( RUN_SLOW=1 pytest tests/ > all_test.log ) 2>&1 1>/dev/null )"

echo $mytime

# Extract the real time from the time command output and save it to the TIME_FILE
grep real $mytime | awk '{print $2}' > time_output.txt
