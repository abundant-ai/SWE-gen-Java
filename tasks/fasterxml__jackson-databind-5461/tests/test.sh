#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordWithJsonIgnoredMethod5184Test.java" \
   "src/test/java/tools/jackson/databind/records/RecordWithJsonIgnoredMethod5184Test.java"

# Use fully-qualified class name to avoid running the tofix version that has @JacksonTestFailureExpected
./mvnw -B -ntp test -Dtest="tools.jackson.databind.records.RecordWithJsonIgnoredMethod5184Test"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
