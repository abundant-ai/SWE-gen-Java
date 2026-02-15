#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/InvalidLifecycleMethodConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/InvalidLifecycleMethodConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/LifecycleMethodSupersedingTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/LifecycleMethodSupersedingTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test \
    --tests org.junit.jupiter.engine.InvalidLifecycleMethodConfigurationTests \
    --tests org.junit.jupiter.engine.LifecycleMethodSupersedingTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
