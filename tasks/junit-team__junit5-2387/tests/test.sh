#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/extension/CloseableResourceIntegrationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/extension/CloseableResourceIntegrationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/execution"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/execution/ExtensionValuesStoreTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/execution/ExtensionValuesStoreTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/ExtensionContextExecutionTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/ExtensionContextExecutionTests.java"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-engine:test \
  --tests org.junit.jupiter.api.extension.CloseableResourceIntegrationTests \
  --tests org.junit.jupiter.engine.execution.ExtensionValuesStoreTests \
  --tests org.junit.jupiter.engine.extension.ExtensionContextExecutionTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
