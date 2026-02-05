#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockitoutil"
cp "/tests/java/org/mockitoutil/SafeJUnitRuleTest.java" "src/test/java/org/mockitoutil/SafeJUnitRuleTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test class for this PR
./gradlew :test \
  --tests org.mockitoutil.SafeJUnitRuleTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
