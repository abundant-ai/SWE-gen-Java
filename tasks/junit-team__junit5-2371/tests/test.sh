#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestIntegrationTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestNameFormatterTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestNameFormatterTests.java"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-params:test \
  --tests org.junit.jupiter.params.ParameterizedTestExtensionTests \
  --tests org.junit.jupiter.params.ParameterizedTestIntegrationTests \
  --tests org.junit.jupiter.params.ParameterizedTestNameFormatterTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
