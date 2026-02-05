#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Remove CacheCorruptionTest.kt which has compilation issues in BASE state
rm -f okhttp/src/test/java/okhttp3/CacheCorruptionTest.kt

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/EventListenerTest.java" "okhttp/src/test/java/okhttp3/EventListenerTest.java"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/test/java/okhttp3/ServerTruncatesRequestTest.kt"

# Compile test sources (needed since we skipped this during Docker build)
./gradlew :okhttp:compileTestKotlin --no-daemon || true

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :okhttp:test --tests "okhttp3.EventListenerTest" --tests "okhttp3.ServerTruncatesRequestTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
