#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/CollectingErrorsTest.java" "src/test/java/tools/jackson/databind/deser/CollectingErrorsTest.java"

# Run only the specific test class from this PR
mvn test -Dtest=CollectingErrorsTest -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
