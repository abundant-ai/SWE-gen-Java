#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/base-services/src/test/groovy/org/gradle/util"
cp "/tests/platforms/core-runtime/base-services/src/test/groovy/org/gradle/util/PathTest.groovy" "platforms/core-runtime/base-services/src/test/groovy/org/gradle/util/PathTest.groovy"

# Run specific test class using Gradle wrapper
./gradlew :base-services:test --tests "org.gradle.util.PathTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
