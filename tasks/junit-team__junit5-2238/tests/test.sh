#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core"
cp "/tests/junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core/ConfigurationParametersFactoryForTests.java" "junit-platform-launcher/src/testFixtures/java/org/junit/platform/launcher/core/ConfigurationParametersFactoryForTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/HierarchicalTestExecutorTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/hierarchical/HierarchicalTestExecutorTests.java"

# Run the specific test files using Gradle
./gradlew :junit-platform-launcher:test \
  --tests org.junit.platform.launcher.core.ConfigurationParametersFactoryForTests \
  -x compileModule --no-daemon --no-parallel 2>&1
launcher_status=$?

./gradlew :platform-tests:test \
  --tests org.junit.platform.engine.support.hierarchical.HierarchicalTestExecutorTests \
  -x compileModule --no-daemon --no-parallel 2>&1
platform_status=$?

# Both test commands must pass
test_status=$((launcher_status || platform_status))

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
