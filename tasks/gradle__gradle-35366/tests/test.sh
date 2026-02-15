#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/build-option/src/test/groovy/org/gradle/internal/buildoption"
cp "/tests/platforms/core-runtime/build-option/src/test/groovy/org/gradle/internal/buildoption/DefaultInternalOptionsTest.groovy" "platforms/core-runtime/build-option/src/test/groovy/org/gradle/internal/buildoption/DefaultInternalOptionsTest.groovy"

# Run specific test class using Gradle
./gradlew :build-option:test --tests org.gradle.internal.buildoption.DefaultInternalOptionsTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
