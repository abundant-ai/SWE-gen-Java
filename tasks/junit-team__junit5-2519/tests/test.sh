#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/TestLauncherDiscoveryListener.java" "platform-tests/src/test/java/org/junit/platform/launcher/TestLauncherDiscoveryListener.java"

# Temporarily remove JFR test files that have compilation errors
rm -f platform-tests/src/test/java/org/junit/platform/jfr/FlightRecordingExecutionListenerIntegrationTests.java
rm -f platform-tests/src/test/java/org/junit/platform/jfr/FlightRecordingDiscoveryListenerIntegrationTests.java

# This PR changes LauncherDiscoveryListener from abstract class to interface
# TestLauncherDiscoveryListener is a test helper that implements it
# The test is to verify that the helper class compiles successfully
./gradlew :platform-tests:compileTestJava -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
