#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationBuilder.java" "src/test/java/org/mockito/internal/invocation/InvocationBuilder.java"
mkdir -p "src/test/java/org/mockitoutil"
cp "/tests/java/org/mockitoutil/TestBase.java" "src/test/java/org/mockitoutil/TestBase.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Since InvocationBuilder and TestBase are utility classes, not test classes,
# we need to run tests that actually use these utilities to verify the import changes work
./gradlew :test \
  --tests org.mockito.internal.verification.DefaultRegisteredInvocationsTest \
  --tests org.mockito.internal.verification.OnlyTest \
  --tests org.mockito.InvocationFactoryTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
