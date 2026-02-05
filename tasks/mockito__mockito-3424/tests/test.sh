#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/framework"
cp "/tests/java/org/mockito/internal/framework/DefaultMockitoFrameworkTest.java" "src/test/java/org/mockito/internal/framework/DefaultMockitoFrameworkTest.java"

# Run the specific tests for this PR (tests are in the root module)
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.InlineDelegateByteBuddyMockMakerTest --no-daemon
test1_status=$?

./gradlew :test --tests org.mockito.internal.framework.DefaultMockitoFrameworkTest --no-daemon
test2_status=$?

# Overall test status (both must pass)
if [ $test1_status -eq 0 ] && [ $test2_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
