#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/FastFallbackTest.kt" "okhttp/src/jvmTest/java/okhttp3/FastFallbackTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/RouteFailureTest.kt" "okhttp/src/jvmTest/java/okhttp3/RouteFailureTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/test
rm -rf okhttp-testing-support/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :okhttp:jvmTest --tests "okhttp3.FastFallbackTest" --tests "okhttp3.RouteFailureTest" --tests "okhttp3.ServerTruncatesRequestTest" --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
