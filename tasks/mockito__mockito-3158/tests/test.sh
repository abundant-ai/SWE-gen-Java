#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
# NOTE: We don't copy the source file (PlatformUtils.java) here because it's part of the fix.patch
# that the Oracle agent applies. The NOP agent won't have it, so the test should fail to compile.
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/PlatformUtilsTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/PlatformUtilsTest.java"

# The bug.patch removes JUnit Jupiter dependencies, but the HEAD test file needs them.
# Restore them by adding the lines back to build.gradle
# (Note: fix.patch already restores libraries.junitJupiterParams in dependencies.gradle)
sed -i '/testImplementation libraries.assertj/a\    testImplementation libraries.junitJupiterApi\n    testImplementation libraries.junitJupiterParams' build.gradle

# Also add runtime dependencies needed for JUnit Jupiter tests to actually run
sed -i '/testImplementation libraries.junitJupiterParams/a\    testRuntimeOnly libraries.junitJupiterEngine\n    testRuntimeOnly libraries.junitPlatformLauncher' build.gradle

# Configure Gradle to use JUnit Platform for running tests (needed for Jupiter tests)
sed -i '/tasks.named("test", Test) {/a\    useJUnitPlatform()' gradle/java-library.gradle

# Force recompilation by deleting build cache and build directory
rm -rf .gradle/*/fileHashes .gradle/*/executionHistory .gradle/buildOutputCleanup/cache.properties
rm -rf build/classes/java/test

# Run the specific test for this PR
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.PlatformUtilsTest --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
