#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal"
cp "/tests/platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal/FileUtilsTest.groovy" "platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal/FileUtilsTest.groovy"
mkdir -p "platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal"
cp "/tests/platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal/SafeFileLocationUtilsTest.groovy" "platforms/core-runtime/base-services/src/test/groovy/org/gradle/internal/SafeFileLocationUtilsTest.groovy"

# Run specific test classes using Gradle
./gradlew :base-services:test --tests org.gradle.internal.FileUtilsTest --tests org.gradle.internal.SafeFileLocationUtilsTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
