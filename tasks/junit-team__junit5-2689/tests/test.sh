#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example/testkit"
cp "/tests/documentation/src/test/java/example/testkit/EngineTestKitAllEventsDemo.java" "documentation/src/test/java/example/testkit/EngineTestKitAllEventsDemo.java"
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

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel

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
    -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
