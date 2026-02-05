#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/converter"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/converter/DefaultArgumentConverterTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/converter/DefaultArgumentConverterTests.java"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.params.ParameterizedTestIntegrationTests \
    --tests org.junit.jupiter.params.aggregator.DefaultArgumentsAccessorTests \
    --tests org.junit.jupiter.params.converter.DefaultArgumentConverterTests \
    --tests org.junit.jupiter.params.aggregator.ArgumentsAccessorKotlinTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
