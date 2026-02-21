#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/struct"
cp "/tests/java/com/fasterxml/jackson/databind/struct/SingleValueAsArrayTest.java" "src/test/java/com/fasterxml/jackson/databind/struct/SingleValueAsArrayTest.java"

# Run only the specific test class from this PR
./mvnw -B -ntp test -Dtest=SingleValueAsArrayTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
