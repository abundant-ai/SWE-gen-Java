#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/junit-jupiter/src/test/java/org/mockitousage"
cp "/tests/subprojects/junit-jupiter/src/test/java/org/mockitousage/JunitJupiterTest.java" "subprojects/junit-jupiter/src/test/java/org/mockitousage/JunitJupiterTest.java"

# Run the specific test for this PR
./gradlew :junit-jupiter:test --tests org.mockitousage.JunitJupiterTest --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
