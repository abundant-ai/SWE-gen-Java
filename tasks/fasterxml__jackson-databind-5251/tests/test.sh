#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/merge"
cp "/tests/java/com/fasterxml/jackson/databind/deser/merge/CustomMapMerge5237Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/merge/CustomMapMerge5237Test.java"

# Recompile test class after copying updated test file
./mvnw -B -ntp test-compile

# Run the specific test class
./mvnw -B -ntp test -Dtest=CustomMapMerge5237Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
