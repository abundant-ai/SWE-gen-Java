#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example"
cp "/tests/documentation/src/test/java/example/ConditionalTestExecutionDemo.java" "documentation/src/test/java/example/ConditionalTestExecutionDemo.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnOsConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnOsConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnOsIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnOsIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnOsConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnOsConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnOsIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnOsIntegrationTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test \
    --tests org.junit.jupiter.api.condition.DisabledOnOsConditionTests \
    --tests org.junit.jupiter.api.condition.DisabledOnOsIntegrationTests \
    --tests org.junit.jupiter.api.condition.EnabledOnOsConditionTests \
    --tests org.junit.jupiter.api.condition.EnabledOnOsIntegrationTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
