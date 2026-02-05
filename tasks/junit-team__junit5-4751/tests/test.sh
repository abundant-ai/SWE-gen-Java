#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/aggregator/DefaultArgumentsAccessorTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/converter"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/converter/DefaultArgumentConverterTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/converter/DefaultArgumentConverterTests.java"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/params/aggregator/ArgumentsAccessorKotlinTests.kt"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/support/conversion"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/support/conversion/ConversionSupportTests.java" "platform-tests/src/test/java/org/junit/platform/commons/support/conversion/ConversionSupportTests.java"

# Run the specific tests for this PR
./gradlew :jupiter-tests:test --tests "*TempDirectoryTests" --tests "*ParameterizedTestIntegrationTests" --tests "*DefaultArgumentsAccessorTests" --tests "*DefaultArgumentConverterTests" --tests "*ArgumentsAccessorKotlinTests" :platform-tests:test --tests "*ConversionSupportTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
