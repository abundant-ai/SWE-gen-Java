#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/discovery/DiscoverySelectorResolverTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/discovery/DiscoverySelectorResolverTests.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-engine:test \
  --tests org.junit.jupiter.engine.discovery.DiscoverySelectorResolverTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status_jupiter=$?

./gradlew :junit-vintage-engine:test \
  --tests org.junit.vintage.engine.VintageTestEngineExecutionTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status_vintage=$?

# Both tests must pass
if [ $test_status_jupiter -eq 0 ] && [ $test_status_vintage -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
