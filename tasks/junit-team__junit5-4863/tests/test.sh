#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/RandomlyOrderedTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/RandomlyOrderedTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/AbstractJupiterTestEngineTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/AbstractJupiterTestEngineTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/StandardTestClassTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/StandardTestClassTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedClassTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/OrderedClassTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryCleanupTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryCleanupTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ForkJoinDeadLockTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ForkJoinDeadLockTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ParallelExecutionIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/ParallelExecutionIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherFactoryTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherFactoryTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/listeners"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/listeners/UniqueIdTrackingListenerIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/listeners/UniqueIdTrackingListenerIntegrationTests.java"

# Run the specific tests for this PR
./gradlew :jupiter-tests:test --tests "*RandomlyOrderedTests" --tests "*AbstractJupiterTestEngineTests" --tests "*StandardTestClassTests" --tests "*DiscoveryTests" --tests "*OrderedClassTests" --tests "*TempDirectoryCleanupTests" :platform-tests:test --tests "*DiscoverySelectorsTests" --tests "*ForkJoinDeadLockTests" --tests "*ParallelExecutionIntegrationTests" --tests "*LauncherFactoryTests" --tests "*UniqueIdTrackingListenerIntegrationTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
