#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tests:testClasses :platform-tooling-support-tests:testClasses --no-daemon --no-parallel

# Run the specific test class from this PR
./gradlew :platform-tests:test --tests org.junit.platform.launcher.core.DefaultLauncherTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
