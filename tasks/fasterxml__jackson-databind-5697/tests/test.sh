#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordWithListOfRecordNullHandling3084Test.java" "src/test/java/tools/jackson/databind/records/RecordWithListOfRecordNullHandling3084Test.java"

# Recompile test sources after copying updated test file
mvn -B -ff -ntp test-compile -DskipTests 2>&1

# Run only the specific test class
mvn -B -ff -ntp test -Dtest=RecordWithListOfRecordNullHandling3084Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
