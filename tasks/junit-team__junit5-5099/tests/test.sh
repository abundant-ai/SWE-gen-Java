#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/NodeTreeWalkerIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/NodeTreeWalkerIntegrationTests.java"

# Run the specific tests for NodeTreeWalkerIntegrationTests
./gradlew :platform-tests:test --tests "*NodeTreeWalkerIntegrationTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
