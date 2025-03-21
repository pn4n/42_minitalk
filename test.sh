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

# Run a test with a specific input file
run_file_test() {
    local test_file="$1"
    local test_num="$2"
    
    > $OUT
    
    stdbuf -o0 ./server > $OUT &
    
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

# Run a test with a specific message
# Run a test with a specific message
run_message_test() {
    local message="$1"
    local test_name="$2"
    
    > $OUT
    
    stdbuf -o0 ./server > $OUT &
    SERVER_PID=$!
    
    echo "SPID: $SERVER_PID"

    sleep 0.5
    
    echo -e "${BLUE}Test string${NC}: \"$message\""
    ./client $SERVER_PID "$message"
    
    # Check if output contains the message
    # Use a more reliable method than grep for special characters
    if cat "$OUT" | tr -d '\n' | grep -F -- "$message" > /dev/null; then
        echo -e "${GREEN}✅ Test: $test_name${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Test: $test_name${NC}"
        echo "Expected: \"$message\""
        echo "Received: \"$(cat $OUT)\""
    fi
    
    # Kill server
    kill -9 $SERVER_PID 2>/dev/null
    sleep 0.5  # Give time for server to terminate
}

# Test for giant message
test_giant_message() {
    > $OUT
    
    stdbuf -o0 ./server > $OUT &
    
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
    
    # Generate a 5000 character random string
    MESSAGE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*()_+-={}[]|:;<>,.?/' | fold -w 5000 | head -n 1)
    
    echo "Sending 5000 characters..."
    ./client $PID "$MESSAGE"
    
    # Check if output contains the message
    if grep -q "$MESSAGE" "$OUT"; then
        echo -e "${GREEN}✅ Test: Giant message (5000 chars)${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Test: Giant message (5000 chars)${NC}"
        echo "Message not received correctly"
    fi
    
    # Kill server
    kill -9 $PID 2>/dev/null
    sleep 0.5  # Give time for server to terminate
}

# Test for multiple messages
test_multiple_messages() {
    > $OUT
    
    stdbuf -o0 ./server > $OUT &
    
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
    
    MESSAGES=("Hola" "Tudo bien?" "E como vai o tempo?" "vai andando")
    
    for msg in "${MESSAGES[@]}"; do
        ./client $PID "$msg"
        sleep 0.2
    done
    
    # Check if output contains all messages
    ALL_FOUND=true
    for msg in "${MESSAGES[@]}"; do
        if ! grep -q "$msg" "$OUT"; then
            ALL_FOUND=false
            echo "Message not found: \"$msg\""
        fi
    done
    
    if $ALL_FOUND; then
        echo -e "${GREEN}✅ Test: Multiple messages${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ Test: Multiple messages${NC}"
        echo "Not all messages were received correctly"
    fi
    
    # Kill server
    kill -9 $PID 2>/dev/null
    sleep 0.5  # Give time for server to terminate
}

# Run special character test from Fsoares
test_special_chars() {
    MESSAGE="Test \`~(*123!@#$%^&*(_+-=][}{';:.></|\\?"
    run_message_test "$MESSAGE" "Special characters"
    ((TOTAL_COUNT++))
}

# Run unicode character test (bonus)
test_unicode_chars() {
    MESSAGE="Test \`~(*123!@#$%^&*(_+-=][}{';:.></|\\? Ž (╯°□°)╯︵ ┻━┻"
    run_message_test "$MESSAGE" "Unicode characters (bonus)"
    ((TOTAL_COUNT++))
}

echo "===== RUNNING TESTS ====="

# Find all test files in the tests directory
TEST_FILES=$(find "$TESTS_DIR" -type f -name "test*" | sort)

# Run each file test
for test_file in $TEST_FILES; do
    ((TOTAL_COUNT++))
    run_file_test "$test_file" "$TOTAL_COUNT"
done

# Run Fsoares tests
echo -e "\n${PURPLE}[Fsoares Tests]${NC}"

# Special character test
test_special_chars

# Giant message test
test_giant_message
((TOTAL_COUNT++))

# Multiple messages test
test_multiple_messages
((TOTAL_COUNT++))

# Bonus test
echo -e "\n${PURPLE}[Bonus Tests]${NC}"
test_unicode_chars

rm -f $OUT

echo "===== SUMMARY ====="
echo "passed: $SUCCESS_COUNT/$TOTAL_COUNT"
if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo -e "${GREEN}All tests passed 🎉${NC}"
else
    echo -e "${RED}Some tests failed 👎${NC}"
    exit 1
fi
