#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordExternalPropertyGeneric3786Test.java" "src/test/java/tools/jackson/databind/records/RecordExternalPropertyGeneric3786Test.java"

# Run only the specific test class from this PR
mvn -B -ff -ntp test -Dtest=RecordExternalPropertyGeneric3786Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
