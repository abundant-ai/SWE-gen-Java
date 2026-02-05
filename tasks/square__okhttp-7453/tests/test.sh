#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/EventListenerTest.java" "okhttp/src/test/java/okhttp3/EventListenerTest.java"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/test/java/okhttp3/ServerTruncatesRequestTest.kt"

# Recompile test sources after copying
./gradlew compileTestKotlin --no-daemon || true

# Run only the test classes for this PR
./gradlew :okhttp:test --tests "okhttp3.EventListenerTest" \
         :okhttp:test --tests "okhttp3.ServerTruncatesRequestTest" \
         --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
