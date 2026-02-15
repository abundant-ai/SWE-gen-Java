#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/CsvArgumentsProviderTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/CsvArgumentsProviderTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/CsvFileArgumentsProviderTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/CsvFileArgumentsProviderTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/MockCsvAnnotationBuilder.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/MockCsvAnnotationBuilder.java"
mkdir -p "junit-jupiter-params/src/test/resources"
cp "/tests/junit-jupiter-params/src/test/resources/default-max-chars.csv" "junit-jupiter-params/src/test/resources/default-max-chars.csv"
mkdir -p "junit-jupiter-params/src/test/resources"
cp "/tests/junit-jupiter-params/src/test/resources/exceeds-default-max-chars.csv" "junit-jupiter-params/src/test/resources/exceeds-default-max-chars.csv"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-params:test \
  --tests org.junit.jupiter.params.provider.CsvArgumentsProviderTests \
  --tests org.junit.jupiter.params.provider.CsvFileArgumentsProviderTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
