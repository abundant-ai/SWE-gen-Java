#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-commons/src/testFixtures/java/org/junit/platform/commons/test"
cp "/tests/junit-platform-commons/src/testFixtures/java/org/junit/platform/commons/test/PreconditionAssertions.java" "junit-platform-commons/src/testFixtures/java/org/junit/platform/commons/test/PreconditionAssertions.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherPreconditionTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/LauncherPreconditionTests.java"

# Run the specific test for LauncherPreconditionTests
./gradlew :platform-tests:test --tests "*LauncherPreconditionTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
