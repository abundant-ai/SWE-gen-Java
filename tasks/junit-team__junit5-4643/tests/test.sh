#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/condition/EnabledForJreRangeConditionTests.java"

# Run the specific test class for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.api.condition.EnabledForJreRangeConditionTests --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
