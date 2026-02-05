#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-console/src/main/java/org/junit/platform/console/options"
cp "/tests/junit-platform-console/src/main/java/org/junit/platform/console/options/TestConsoleOutputOptionsMixin.java" "junit-platform-console/src/main/java/org/junit/platform/console/options/TestConsoleOutputOptionsMixin.java"
mkdir -p "junit-platform-console/src/main/java/org/junit/platform/console/options"
cp "/tests/junit-platform-console/src/main/java/org/junit/platform/console/options/TestDiscoveryOptionsMixin.java" "junit-platform-console/src/main/java/org/junit/platform/console/options/TestDiscoveryOptionsMixin.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/ConsoleDetailsTests.java" "platform-tests/src/test/java/org/junit/platform/console/ConsoleDetailsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/ConsoleLauncherIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/console/ConsoleLauncherIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/options"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/options/CommandLineOptionsParsingTests.java" "platform-tests/src/test/java/org/junit/platform/console/options/CommandLineOptionsParsingTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :platform-tests:test --tests org.junit.platform.console.ConsoleDetailsTests \
    --tests org.junit.platform.console.ConsoleLauncherIntegrationTests \
    --tests org.junit.platform.console.options.CommandLineOptionsParsingTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
