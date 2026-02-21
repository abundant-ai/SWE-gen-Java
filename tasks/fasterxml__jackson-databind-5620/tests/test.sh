#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/ser/jdk"
cp "/tests/java/com/fasterxml/jackson/databind/ser/jdk/AtomicTypeSerializationTest.java" "src/test/java/com/fasterxml/jackson/databind/ser/jdk/AtomicTypeSerializationTest.java"

# Recompile test classes after copying updated test file
mvn -B -ff -ntp test-compile -DskipTests

# Run only the specific test class from the PR
mvn -B -ff -ntp test -Dtest=AtomicTypeSerializationTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
