#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tooling-support-tests:testClasses --no-daemon --no-parallel

# Run the specific test class from this PR
./gradlew :platform-tooling-support-tests:test \
    --tests platform.tooling.support.tests.StandaloneTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
