#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/AntStarterTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/AntStarterTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/GradleStarterTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/GradleStarterTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MavenStarterTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MavenStarterTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/XmlAssertions.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/XmlAssertions.java"
mkdir -p "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/AntStarterTests_snapshots"
cp "/tests/platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/AntStarterTests_snapshots/open-test-report.xml.snapshot" "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/AntStarterTests_snapshots/open-test-report.xml.snapshot"
mkdir -p "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/GradleStarterTests_snapshots"
cp "/tests/platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/GradleStarterTests_snapshots/open-test-report.xml.snapshot" "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/GradleStarterTests_snapshots/open-test-report.xml.snapshot"
mkdir -p "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/MavenStarterTests_snapshots"
cp "/tests/platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/MavenStarterTests_snapshots/open-test-report.xml.snapshot" "platform-tooling-support-tests/src/test/resources/platform/tooling/support/tests/MavenStarterTests_snapshots/open-test-report.xml.snapshot"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
./gradlew :platform-tooling-support-tests:test --tests platform.tooling.support.tests.AntStarterTests \
    --tests platform.tooling.support.tests.GradleStarterTests \
    --tests platform.tooling.support.tests.MavenStarterTests \
    --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
