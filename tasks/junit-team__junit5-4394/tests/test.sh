#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-engine/src/main/java/org/junit/platform/engine"
cp "/tests/junit-platform-engine/src/main/java/org/junit/platform/engine/TestDescriptor.java" "junit-platform-engine/src/main/java/org/junit/platform/engine/TestDescriptor.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/CompositeTestDescriptorVisitorTests.java" "platform-tests/src/test/java/org/junit/platform/engine/CompositeTestDescriptorVisitorTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test class for this PR
./gradlew :platform-tests:test --tests org.junit.platform.engine.CompositeTestDescriptorVisitorTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
