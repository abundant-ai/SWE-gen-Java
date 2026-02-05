#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedClassIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedClassIntegrationTests.java"

# Run the specific tests for ParameterizedClassIntegrationTests
./gradlew :jupiter-tests:test --tests "*ParameterizedClassIntegrationTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
