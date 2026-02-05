#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/AbstractJupiterTestEngineTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/AbstractJupiterTestEngineTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/TestInstanceLifecycleConfigurationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/TestInstanceLifecycleConfigurationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoverySelectorResolverTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoverySelectorResolverTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/jfr"
cp "/tests/platform-tests/src/test/java/org/junit/platform/jfr/FlightRecordingDiscoveryListenerIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/jfr/FlightRecordingDiscoveryListenerIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/LoggingLauncherDiscoveryListenerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/listeners/discovery/LoggingLauncherDiscoveryListenerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/testkit/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineDiscoveryResultsIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineDiscoveryResultsIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/testkit/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineTestKitTests.java" "platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineTestKitTests.java"

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.AbstractJupiterTestEngineTests \
    --tests org.junit.jupiter.engine.TestInstanceLifecycleConfigurationTests \
    --tests org.junit.jupiter.engine.discovery.DiscoverySelectorResolverTests \
    --tests org.junit.jupiter.engine.discovery.DiscoveryTests \
    :platform-tests:test --tests org.junit.platform.jfr.FlightRecordingDiscoveryListenerIntegrationTests \
    --tests org.junit.platform.launcher.core.DefaultLauncherTests \
    --tests org.junit.platform.launcher.listeners.discovery.LoggingLauncherDiscoveryListenerTests \
    --tests org.junit.platform.testkit.engine.EngineDiscoveryResultsIntegrationTests \
    --tests org.junit.platform.testkit.engine.EngineTestKitTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
