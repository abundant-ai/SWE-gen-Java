#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator/AggregatorIntegrationTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator/AggregatorIntegrationTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java"
mkdir -p "junit-jupiter-params/src/test/kotlin/org/junit/jupiter/params/aggregator"
cp "/tests/junit-jupiter-params/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt" "junit-jupiter-params/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-params:test \
    --tests org.junit.jupiter.params.aggregator.AggregatorIntegrationTests \
    --tests org.junit.jupiter.params.aggregator.DefaultArgumentsAccessorTests \
    --tests org.junit.jupiter.params.aggregator.ArgumentsAccessorKotlinTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
