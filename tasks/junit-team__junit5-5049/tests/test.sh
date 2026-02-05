#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineDiscoveryTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineDiscoveryTests.java"

# Run the specific tests for VintageTestEngineDiscoveryTests
./gradlew :junit-vintage-engine:test --tests "*VintageTestEngineDiscoveryTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
