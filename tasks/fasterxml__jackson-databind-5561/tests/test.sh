#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordIgnoreGetters4157Test.java" "src/test/java/tools/jackson/databind/records/RecordIgnoreGetters4157Test.java"
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordIgnoreNonAccessorGetterTest.java" "src/test/java/tools/jackson/databind/records/RecordIgnoreNonAccessorGetterTest.java"

# Recompile test classes after copying updated test files
mvn test-compile -q 2>&1 || true

# Run only the specific test classes from this PR
mvn test -Dtest="RecordIgnoreGetters4157Test,RecordIgnoreNonAccessorGetterTest" -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
