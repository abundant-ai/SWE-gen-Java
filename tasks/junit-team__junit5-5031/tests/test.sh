#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/provider/CsvArgumentsProviderTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/provider/CsvArgumentsProviderTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/provider/CsvFileArgumentsProviderTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/provider/CsvFileArgumentsProviderTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/provider/MockCsvAnnotationBuilder.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/provider/MockCsvAnnotationBuilder.java"

# Run the specific tests for CsvArgumentsProviderTests and CsvFileArgumentsProviderTests
./gradlew :jupiter-tests:test --tests "*CsvArgumentsProviderTests" --tests "*CsvFileArgumentsProviderTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
