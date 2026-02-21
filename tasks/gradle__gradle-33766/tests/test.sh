#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/kotlin-dsl/src/test/kotlin/org/gradle/kotlin/dsl"
cp "/tests/platforms/core-configuration/kotlin-dsl/src/test/kotlin/org/gradle/kotlin/dsl/KotlinBuildScriptPatternTest.kt" "platforms/core-configuration/kotlin-dsl/src/test/kotlin/org/gradle/kotlin/dsl/KotlinBuildScriptPatternTest.kt"

# Run specific test class using Gradle wrapper
./gradlew :kotlin-dsl:test --tests "org.gradle.kotlin.dsl.KotlinBuildScriptPatternTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
