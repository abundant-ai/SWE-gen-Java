#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/TagIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/TagIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DefaultLauncherTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/ExecutionListenerAdapterTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/ExecutionListenerAdapterTests.java"
mkdir -p "platform-tests/src/test/resources"
cp "/tests/platform-tests/src/test/resources/log4j2-test.xml" "platform-tests/src/test/resources/log4j2-test.xml"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-engine:test \
  --tests org.junit.jupiter.engine.NestedTestClassesTests \
  -x compileModule --no-daemon --no-parallel 2>&1
jupiter_status=$?

./gradlew :platform-tests:test \
  --tests org.junit.platform.launcher.TagIntegrationTests \
  --tests org.junit.platform.launcher.core.DefaultLauncherTests \
  --tests org.junit.platform.launcher.core.ExecutionListenerAdapterTests \
  -x compileModule --no-daemon --no-parallel 2>&1
platform_status=$?

# Both test commands must pass
test_status=$((jupiter_status || platform_status))

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
