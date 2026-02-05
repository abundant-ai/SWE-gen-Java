#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/matchers"
cp "/tests/java/org/mockito/internal/matchers/EqualsTest.java" "src/test/java/org/mockito/internal/matchers/EqualsTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/argumentmatching"
cp "/tests/java/org/mockito/internal/verification/argumentmatching/ArgumentMatchingToolTest.java" "src/test/java/org/mockito/internal/verification/argumentmatching/ArgumentMatchingToolTest.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/IMethods.java" "src/test/java/org/mockitousage/IMethods.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/MethodsImpl.java" "src/test/java/org/mockitousage/MethodsImpl.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.matchers.EqualsTest \
  --tests org.mockito.internal.verification.argumentmatching.ArgumentMatchingToolTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
