#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordBackReference5188Test.java" "src/test/java/tools/jackson/databind/records/RecordBackReference5188Test.java"

# Recompile test classes after copying updated test file
mvn -B -ff -ntp test-compile -DskipTests 2>&1 | tail -5

# Run only the specific test class from this PR
mvn -B -ff -ntp test -Dtest=RecordBackReference5188Test -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
