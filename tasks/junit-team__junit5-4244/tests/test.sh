#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/ClasspathAlignmentCheckerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/ClasspathAlignmentCheckerTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/JavaVersionsTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/JavaVersionsTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MavenEnvVars.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MavenEnvVars.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MultiReleaseJarTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/MultiReleaseJarTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/UnalignedClasspathTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/UnalignedClasspathTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR
echo "Running platform-tests..."
./gradlew :platform-tests:test --tests org.junit.platform.launcher.core.ClasspathAlignmentCheckerTests \
    --no-daemon --no-configuration-cache 2>&1
platform_tests_status=$?
echo "Platform tests exit status: $platform_tests_status"

echo "Running platform-tooling-support-tests..."
./gradlew :platform-tooling-support-tests:test --tests platform.tooling.support.tests.JavaVersionsTests \
    --tests platform.tooling.support.tests.MavenEnvVars \
    --tests platform.tooling.support.tests.MultiReleaseJarTests \
    --tests platform.tooling.support.tests.UnalignedClasspathTests \
    --no-daemon --no-configuration-cache 2>&1
tooling_tests_status=$?
echo "Platform tooling support tests exit status: $tooling_tests_status"

# Both test suites must pass
if [ $platform_tests_status -eq 0 ] && [ $tooling_tests_status -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
