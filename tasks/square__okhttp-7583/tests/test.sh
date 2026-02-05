#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheTest.java" "okhttp/src/jvmTest/java/okhttp3/CacheTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Recompile test sources after copying
./gradlew compileTestKotlin --no-daemon || true

# Run only the test classes for this PR
./gradlew :mockwebserver3:test --tests "mockwebserver3.MockWebServerTest" \
         :okhttp:test --tests "okhttp3.CacheTest" \
         :okhttp:test --tests "okhttp3.URLConnectionTest" \
         :okhttp:test --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
         --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
