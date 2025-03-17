#!/bin/bash

OUT="out.txt"

> $OUT

stdbuf -o0 ./server > $OUT &

while [ "$(wc -l < "$OUT")" -eq 0 ]; do
    sleep 0.1
done

PID=$(grep -o "PID: [0-9]* " $OUT | cut -d' ' -f2)


echo "SPID: $PID"

TEST_FILE="header.h"


 > $OUT

while [ "$(wc -l < "$OUT")" -gt 0 ]; do
    sleep 0.1
	echo "$a"
done


# echo "$PID"

# ./client "$PID" "sas)"

# kill -9 $PID

# rm $OUT

./client $PID "$(cat $TEST_FILE)"

# echo "./client $PID"

diff $TEST_FILE $OUT

kill -9 $PID