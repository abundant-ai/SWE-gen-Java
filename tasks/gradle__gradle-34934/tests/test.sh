#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/core/src/test/groovy/org/gradle/api/internal/project"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/api/internal/project/DefaultProjectRegistryTest.java" "subprojects/core/src/test/groovy/org/gradle/api/internal/project/DefaultProjectRegistryTest.java"

# Run specific test class using Gradle
./gradlew :core:test --tests org.gradle.api.internal.project.DefaultProjectRegistryTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
