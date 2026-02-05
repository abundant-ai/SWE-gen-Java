#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationBuilder.java" "src/test/java/org/mockito/internal/invocation/InvocationBuilder.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java"

# Run the specific test files for this PR
./gradlew :test \
  --tests org.mockito.internal.verification.checkers.MissingInvocationCheckerTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
