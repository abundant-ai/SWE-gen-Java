#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/DuplexTest.java" "okhttp/src/jvmTest/java/okhttp3/DuplexTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/EventListenerTest.java" "okhttp/src/jvmTest/java/okhttp3/EventListenerTest.java"

# Compile test sources to ensure they're up-to-date after copying HEAD test files
./gradlew --no-daemon compileTestKotlin compileTestJava || true

# Run specific test classes using Gradle
./gradlew --no-daemon :mockwebserver:jvmTest \
  --tests "mockwebserver3.MockWebServerTest"

./gradlew --no-daemon :okhttp:jvmTest \
  --tests "okhttp3.CallTest" \
  --tests "okhttp3.DuplexTest" \
  --tests "okhttp3.EventListenerTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
