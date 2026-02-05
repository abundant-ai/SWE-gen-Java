#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform"
cp "/tests/platform-tests/src/test/java/org/junit/platform/StackTracePruningTests.java" "platform-tests/src/test/java/org/junit/platform/StackTracePruningTests.java"

# Run the specific tests for this PR
./gradlew :platform-tests:test --tests "*StackTracePruningTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
