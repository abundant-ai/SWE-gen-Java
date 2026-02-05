#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TimeoutConfigurationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TimeoutConfigurationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"

# Run the specific tests for this PR
./gradlew :jupiter-tests:test --tests "*DefaultJupiterConfigurationTests" --tests "*ExtensionContextTests" --tests "*TimeoutConfigurationTests" :platform-tests:test --tests "*DefaultLauncherTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
