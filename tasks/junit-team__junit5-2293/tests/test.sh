#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core"
cp "/tests/junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core/ConfigurationParametersFactoryForTests.java" "junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core/ConfigurationParametersFactoryForTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherConfigurationParametersTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherConfigurationParametersTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/testkit/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineTestKitTests.java" "platform-tests/src/test/java/org/junit/platform/testkit/engine/EngineTestKitTests.java"

# Run the specific test files using Gradle
./gradlew :junit-platform-launcher:test \
  --tests org.junit.platform.launcher.core.ConfigurationParametersFactoryForTests \
  :platform-tests:test \
  --tests org.junit.platform.launcher.core.LauncherConfigurationParametersTests \
  --tests org.junit.platform.testkit.engine.EngineTestKitTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
