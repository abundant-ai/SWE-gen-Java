#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/store"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/store/NamespacedHierarchicalStoreTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/store/NamespacedHierarchicalStoreTests.java"

# Run the specific test for NamespacedHierarchicalStoreTests
./gradlew :platform-tests:test --tests "*NamespacedHierarchicalStoreTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
