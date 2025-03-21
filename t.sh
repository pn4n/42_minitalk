#!/bin/bash

OUT="out.txt"
TESTS_DIR="tests"
SUCCESS_COUNT=0
TOTAL_COUNT=0
SPID=""

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
NC="\033[0m" # No Color


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
	PID=$!
    
    echo "SPID: $PID"

	sleep 0.5
    
    ./client $PID "$(cat $test_file)"
    
    # Check if output matches test file
    if diff -q --strip-trailing-cr "$test_file" "$OUT" > /dev/null; then
        echo -e "${GREEN}✅ Test $test_num: $(basename $test_file)${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Test $test_num: $(basename $test_file)${NC}"
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
    echo -e "${GREEN}all tests passed 🎉${NC}"
else
    echo -e "${RED}some tests failed 👎${NC}"
    exit 1
fi
