#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-sse/src/test/java/okhttp3/sse/internal"
cp "/tests/okhttp-sse/src/test/java/okhttp3/sse/internal/EventSourceHttpTest.java" "okhttp-sse/src/test/java/okhttp3/sse/internal/EventSourceHttpTest.java"

# Recompile test sources after copying
./gradlew :okhttp-sse:compileTestJava --no-daemon || true

# Run only the test class for this PR
./gradlew :okhttp-sse:test --tests "okhttp3.sse.internal.EventSourceHttpTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
