#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt" "okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/RequestTest.kt" "okhttp/src/jvmTest/java/okhttp3/RequestTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/UtilTest.kt" "okhttp/src/jvmTest/java/okhttp3/internal/UtilTest.kt"

# Compile test sources to ensure they're up-to-date after copying HEAD test files
./gradlew --no-daemon compileTestKotlin compileTestJava || true

# Run specific test classes using Gradle
./gradlew --no-daemon :okhttp:jvmTest \
  --tests "okhttp3.KotlinSourceModernTest" \
  --tests "okhttp3.RequestTest" \
  --tests "okhttp3.internal.UtilTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
