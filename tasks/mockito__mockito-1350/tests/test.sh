#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/junit-jupiter/src/test/java/org/mockitousage"
cp "/tests/subprojects/junit-jupiter/src/test/java/org/mockitousage/JunitJupiterTest.java" "subprojects/junit-jupiter/src/test/java/org/mockitousage/JunitJupiterTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :junit-jupiter:cleanTest --no-daemon

# Run the specific test for this PR (in the junit-jupiter subproject)
./gradlew :junit-jupiter:test \
  --tests org.mockitousage.JunitJupiterTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
