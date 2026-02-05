#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/support"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/support/ReflectionSupportTests.java" "platform-tests/src/test/java/org/junit/platform/commons/support/ReflectionSupportTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/support"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/support/ResourceSupportTests.java" "platform-tests/src/test/java/org/junit/platform/commons/support/ResourceSupportTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/ModuleSelectorTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/ModuleSelectorTests.java"

# Run the specific tests for this PR
./gradlew :platform-tests:test --tests "*ReflectionSupportTests" --tests "*ResourceSupportTests" --tests "*DiscoverySelectorsTests" --tests "*ModuleSelectorTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
