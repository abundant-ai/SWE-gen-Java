#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledForJreRangeIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnJreConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnJreConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledOnJreIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnJreConditionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnJreConditionTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledOnJreIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/JRETests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/JRETests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test \
    --tests org.junit.jupiter.api.condition.DisabledForJreRangeConditionTests \
    --tests org.junit.jupiter.api.condition.DisabledForJreRangeIntegrationTests \
    --tests org.junit.jupiter.api.condition.DisabledOnJreConditionTests \
    --tests org.junit.jupiter.api.condition.DisabledOnJreIntegrationTests \
    --tests org.junit.jupiter.api.condition.EnabledForJreRangeConditionTests \
    --tests org.junit.jupiter.api.condition.EnabledForJreRangeIntegrationTests \
    --tests org.junit.jupiter.api.condition.EnabledOnJreConditionTests \
    --tests org.junit.jupiter.api.condition.EnabledOnJreIntegrationTests \
    --tests org.junit.jupiter.api.condition.JRETests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
