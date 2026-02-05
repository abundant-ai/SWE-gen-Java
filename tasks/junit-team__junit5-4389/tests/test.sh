#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/AbortOnFailureLauncherDiscoveryListenerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/AbortOnFailureLauncherDiscoveryListenerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/LoggingLauncherDiscoveryListenerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/LoggingLauncherDiscoveryListenerTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.NestedTestClassesTests \
    :platform-tests:test --tests org.junit.platform.launcher.core.DefaultLauncherTests \
    --tests org.junit.platform.launcher.listeners.discovery.AbortOnFailureLauncherDiscoveryListenerTests \
    --tests org.junit.platform.launcher.listeners.discovery.LoggingLauncherDiscoveryListenerTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
