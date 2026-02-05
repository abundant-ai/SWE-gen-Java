#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/commonTest/kotlin/okhttp3/internal"
cp "/tests/okhttp/src/commonTest/kotlin/okhttp3/internal/IsProbablyUtf8Test.kt" "okhttp/src/commonTest/kotlin/okhttp3/internal/IsProbablyUtf8Test.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt"

# Run only the specific test classes using Gradle with JUnit filter
./gradlew :okhttp:jvmTest --tests "okhttp3.internal.IsProbablyUtf8Test" --tests "okhttp3.RequestTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
