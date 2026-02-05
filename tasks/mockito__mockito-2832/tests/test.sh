#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/verification/argumentmatching"
cp "/tests/java/org/mockito/internal/verification/argumentmatching/ArgumentMatchingToolTest.java" "src/test/java/org/mockito/internal/verification/argumentmatching/ArgumentMatchingToolTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"

# Run the specific tests for this PR
./gradlew :test \
  --tests org.mockito.internal.verification.argumentmatching.ArgumentMatchingToolTest \
  --tests org.mockito.internal.verification.checkers.MissingInvocationCheckerTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest \
  --no-daemon --rerun-tasks

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
