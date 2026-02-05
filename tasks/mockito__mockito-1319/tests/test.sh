#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationsFinderTest.java" "src/test/java/org/mockito/internal/invocation/InvocationsFinderTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/NumberOfInvocationsCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/NumberOfInvocationsCheckerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/NumberOfInvocationsInOrderCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/NumberOfInvocationsInOrderCheckerTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR
./gradlew :test \
  --tests org.mockito.internal.invocation.InvocationsFinderTest \
  --tests org.mockito.internal.verification.checkers.NumberOfInvocationsCheckerTest \
  --tests org.mockito.internal.verification.checkers.NumberOfInvocationsInOrderCheckerTest \
  --tests org.mockitousage.verification.DescriptiveMessagesOnVerificationInOrderErrorsTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
