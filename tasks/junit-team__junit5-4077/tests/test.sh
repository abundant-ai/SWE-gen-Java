#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tooling-support-tests/projects/vintage/src/test/java"
cp "/tests/platform-tooling-support-tests/projects/vintage/src/test/java/DefaultPackageTest.java" "platform-tooling-support-tests/projects/vintage/src/test/java/DefaultPackageTest.java"
mkdir -p "platform-tooling-support-tests/projects/vintage/src/test/java/com/example/vintage"
cp "/tests/platform-tooling-support-tests/projects/vintage/src/test/java/com/example/vintage/VintageTest.java" "platform-tooling-support-tests/projects/vintage/src/test/java/com/example/vintage/VintageTest.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tooling-support-tests:testClasses --no-daemon --no-configuration-cache

# Run the vintage integration tests that use these test files
./gradlew :platform-tooling-support-tests:test --tests platform.tooling.support.tests.VintageGradleIntegrationTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
