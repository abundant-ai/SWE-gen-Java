#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/ClassSelectorTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/ClassSelectorTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/MethodSelectorTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/MethodSelectorTests.java"

# Run the specific test files using Gradle
./gradlew :platform-tests:test \
  --tests org.junit.platform.engine.discovery.ClassSelectorTests \
  --tests org.junit.platform.engine.discovery.DiscoverySelectorsTests \
  --tests org.junit.platform.engine.discovery.MethodSelectorTests \
  -x compileModule -x verifyOSGi --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
