#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-vintage-engine/src/main/java/org/junit/vintage/engine/execution"
cp "/tests/junit-vintage-engine/src/main/java/org/junit/vintage/engine/execution/TestRun.java" "junit-vintage-engine/src/main/java/org/junit/vintage/engine/execution/TestRun.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java"

# Run the specific test class for this PR
./gradlew :junit-vintage-engine:test --tests org.junit.vintage.engine.VintageTestEngineExecutionTests --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
