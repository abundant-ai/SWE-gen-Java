#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordUnwrapped5115Test.java" "src/test/java/tools/jackson/databind/records/RecordUnwrapped5115Test.java"

# Recompile test sources to pick up the new test file
mvn test-compile -B -ntp -DskipTests -q

# Run only the specific test class from this PR
mvn test -B -ntp -Dtest=tools.jackson.databind.records.RecordUnwrapped5115Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
