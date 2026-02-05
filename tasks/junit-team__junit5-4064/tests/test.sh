#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension"
cp "/tests/junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension/TestInstantiationAwareExtension.java" "junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension/TestInstantiationAwareExtension.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/execution"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/execution/InterceptingExecutableInvokerTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/execution/InterceptingExecutableInvokerTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TestInstanceFactoryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TestInstanceFactoryTests.java"

# Rebuild test classes to pick up the changes
./gradlew :jupiter-tests:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.execution.InterceptingExecutableInvokerTests \
    --tests org.junit.jupiter.engine.extension.TestInstanceFactoryTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
