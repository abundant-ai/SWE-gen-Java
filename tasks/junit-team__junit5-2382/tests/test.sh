#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/LockManagerTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/LockManagerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/NodeTreeWalkerIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/NodeTreeWalkerIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ParallelExecutionIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ParallelExecutionIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ResourceLockSupport.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ResourceLockSupport.java"

# Run the specific test files using Gradle
./gradlew :platform-tests:test \
  --tests org.junit.platform.engine.support.hierarchical.LockManagerTests \
  --tests org.junit.platform.engine.support.hierarchical.NodeTreeWalkerIntegrationTests \
  --tests org.junit.platform.engine.support.hierarchical.ParallelExecutionIntegrationTests \
  --tests org.junit.platform.engine.support.hierarchical.ResourceLockSupport \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
