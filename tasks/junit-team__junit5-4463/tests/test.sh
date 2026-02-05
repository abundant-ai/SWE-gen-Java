#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedClassTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedClassTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedMethodTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedMethodTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.extension.OrderedClassTests \
    --tests org.junit.jupiter.engine.extension.OrderedMethodTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
