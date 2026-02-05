#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/LifecycleMethodUtilsTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/LifecycleMethodUtilsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/discovery/EngineDiscoveryRequestResolverTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/discovery/EngineDiscoveryRequestResolverTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.descriptor.LifecycleMethodUtilsTests \
    :platform-tests:test --tests org.junit.platform.engine.support.discovery.EngineDiscoveryRequestResolverTests \
    --tests org.junit.platform.launcher.core.DefaultLauncherTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
