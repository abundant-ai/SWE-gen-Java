#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/CustomContextClassLoaderExecutorTests.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/CustomContextClassLoaderExecutorTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java"

# Run the specific test classes for this PR
echo "==== Running tests ===="
./gradlew --no-daemon \
  :platform-tests:test --tests org.junit.platform.console.tasks.CustomContextClassLoaderExecutorTests \
  :platform-tooling-support-tests:test --tests platform.tooling.support.tests.StandaloneTests \
  --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
