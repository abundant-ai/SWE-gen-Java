#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java.jte"
mkdir -p "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java.jte" "jupiter-tests/src/templates/resources/test/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java.jte"

# Rebuild test classes from templates to pick up the changes
./gradlew :jupiter-tests:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
# Note: IntegrationTests contain @Disabled test methods that are tested via reflection by ConditionTests
./gradlew :jupiter-tests:test --tests org.junit.jupiter.api.condition.EnabledOnJreIntegrationTests \
    --tests org.junit.jupiter.api.condition.DisabledOnJreIntegrationTests \
    --tests org.junit.jupiter.api.condition.EnabledOnJreConditionTests \
    --tests org.junit.jupiter.api.condition.DisabledOnJreConditionTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
