#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java"
mkdir -p "subprojects/module-test/src/test/java/org/mockito/moduletest"
cp "/tests/subprojects/module-test/src/test/java/org/mockito/moduletest/ModuleHandlingTest.java" "subprojects/module-test/src/test/java/org/mockito/moduletest/ModuleHandlingTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew cleanTest :module-test:cleanTest --no-daemon

# Run the specific test files for this PR
# Note: Run each test task separately to avoid applying --tests filter globally
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.InlineByteBuddyMockMakerTest.testMockDispatcherIsRelocated --no-daemon && \
./gradlew :module-test:test --tests org.mockito.moduletest.ModuleHandlingTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
