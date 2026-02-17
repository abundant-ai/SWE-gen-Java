#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/launcher/src/test/groovy/org/gradle/launcher/exec"
cp "/tests/platforms/core-runtime/launcher/src/test/groovy/org/gradle/launcher/exec/RootBuildLifecycleBuildActionExecutorTest.groovy" "platforms/core-runtime/launcher/src/test/groovy/org/gradle/launcher/exec/RootBuildLifecycleBuildActionExecutorTest.groovy"

# Run specific test class using Gradle
./gradlew :launcher:test --tests org.gradle.launcher.exec.RootBuildLifecycleBuildActionExecutorTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
