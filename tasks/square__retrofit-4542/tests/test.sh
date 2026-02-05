#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/java-test/src/test/java/retrofit2"
cp "/tests/retrofit/java-test/src/test/java/retrofit2/InvocationTest.java" "retrofit/java-test/src/test/java/retrofit2/InvocationTest.java"

# Run only the specific test from the PR (in java-test submodule)
./gradlew :retrofit:java-test:test --tests retrofit2.InvocationTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
