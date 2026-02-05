#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/InvocationFactoryTest.java" "src/test/java/org/mockito/InvocationFactoryTest.java"
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/StaticMockingExperimentTest.java" "src/test/java/org/mockito/StaticMockingExperimentTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR
./gradlew :test \
  --tests org.mockito.InvocationFactoryTest \
  --tests org.mockito.StaticMockingExperimentTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
