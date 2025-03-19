#!/bin/bash

OUT="out.txt"
TESTS_DIR="tests"
SUCCESS_COUNT=0
TOTAL_COUNT=0
SPID=""
# SNUM=0

# run_serv() {
# 	SNUM=$((1 + $RANDOM % 1000))
# 	> $OUT
# 	stdbuf -o0 ./server $SNUM > $OUT &
	
# 	SPID=""
#     while [ -z "$SPID" ]; do
#         SPID=$(ps aux | grep -P "./server(\s+\d+)?$" | grep -v grep | awk '{print $2}')
#         if [ -z "$SPID" ]; then
#             echo "Waiting for server to start..."
#             sleep 0.2
#         fi
#     done
    
#     echo "SPID: $SPID"
# }
run_test() {
    local test_file="$1"
    local test_num="$2"
    
    > $OUT
    
    stdbuf -o0 ./server 1 > $OUT &
    
    PID=""
    while [ -z "$PID" ]; do
        PID=$(ps aux | grep -P "./server(\s+\d+)?$" | grep -v grep | awk '{print $2}')
        if [ -z "$PID" ]; then
            echo "Waiting for server to start..."
            sleep 0.2
        fi
    done
    
    echo "SPID: $PID"

	sleep 0.5
    
    ./client $PID "$(cat $test_file)"
    
    # Check if output matches test file
    if diff -q --strip-trailing-cr "$test_file" "$OUT" > /dev/null; then
        echo -e "✅ Test $test_num: $(basename $test_file)"
        ((SUCCESS_COUNT++))
    else
        echo -e "❌ Test $test_num: $(basename $test_file)"
        echo "Diff output:"
        diff --strip-trailing-cr "$test_file" "$OUT"
    fi
    
    # Kill server
    kill -9 $PID 2>/dev/null
    sleep 0.5  # Give time for server to terminate
}

# Find all test files in the tests directory
TEST_FILES=$(find "$TESTS_DIR" -type f -name "test*" | sort)

# run_serv

# Run each test
for test_file in $TEST_FILES; do
    ((TOTAL_COUNT++))
    run_test "$test_file" "$TOTAL_COUNT"
done

rm $OUT
# kill -9 $SPID 2>/dev/null

echo "===== SUMMARY ====="
echo "passed: $SUCCESS_COUNT/$TOTAL_COUNT"
if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo "all tests passed 🎉"
else
    echo "some tests failed 👎"
    exit 1
fi
