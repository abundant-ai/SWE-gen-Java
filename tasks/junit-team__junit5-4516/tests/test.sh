#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example"
cp "/tests/documentation/src/test/java/example/ConditionalTestExecutionDemo.java" "documentation/src/test/java/example/ConditionalTestExecutionDemo.java"
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreConditionTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreConditionTests.java.jte"
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java.jte"
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreConditionTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreConditionTests.java.jte"
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java.jte"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeConditionTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeConditionTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeIntegrationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeIntegrationTests.java"

# Run the specific condition test classes that validate the JRE range annotations
echo "==== Running tests ===="
./gradlew --no-daemon \
  :jupiter-tests:test --tests org.junit.jupiter.api.condition.EnabledForJreRangeConditionTests \
  --tests org.junit.jupiter.api.condition.DisabledForJreRangeConditionTests \
  --tests org.junit.jupiter.api.condition.EnabledForJreRangeIntegrationTests \
  --tests org.junit.jupiter.api.condition.DisabledForJreRangeIntegrationTests \
  --tests org.junit.jupiter.api.condition.EnabledOnJreConditionTests \
  --tests org.junit.jupiter.api.condition.DisabledOnJreConditionTests \
  --tests org.junit.jupiter.api.condition.EnabledOnJreIntegrationTests \
  --tests org.junit.jupiter.api.condition.DisabledOnJreIntegrationTests \
  --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
