#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/listeners"
cp "/tests/java/org/mockito/internal/listeners/StubbingLookupNotifierTest.java" "src/test/java/org/mockito/internal/listeners/StubbingLookupNotifierTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific tests for this PR (in the root project)
./gradlew :test \
  --tests org.mockito.internal.listeners.StubbingLookupNotifierTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
