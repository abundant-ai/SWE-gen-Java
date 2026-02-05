#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension"
cp "/tests/junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension/TestTemplateInvocationContextProvider.java" "junit-jupiter-api/src/main/java/org/junit/jupiter/api/extension/TestTemplateInvocationContextProvider.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedClassIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedClassIntegrationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.params.ParameterizedClassIntegrationTests \
    --tests org.junit.jupiter.params.ParameterizedTestExtensionTests \
    --tests org.junit.jupiter.params.ParameterizedTestIntegrationTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
