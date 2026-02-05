#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/concurrentmockito"
cp "/tests/java/org/concurrentmockito/ThreadVerifiesContinuouslyInteractingMockTest.java" "src/test/java/org/concurrentmockito/ThreadVerifiesContinuouslyInteractingMockTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/DeepStubbingTest.java" "src/test/java/org/mockitousage/stubbing/DeepStubbingTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/AtMostXVerificationTest.java" "src/test/java/org/mockitousage/verification/AtMostXVerificationTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific tests for this PR (in the root project)
./gradlew :test \
  --tests org.concurrentmockito.ThreadVerifiesContinuouslyInteractingMockTest \
  --tests org.mockitousage.stubbing.DeepStubbingTest \
  --tests org.mockitousage.verification.AtMostXVerificationTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
