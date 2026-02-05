#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/OkHttpClientTest.kt" "okhttp/src/test/java/okhttp3/OkHttpClientTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/ws"
cp "/tests/okhttp/src/test/java/okhttp3/internal/ws/RealWebSocketTest.kt" "okhttp/src/test/java/okhttp3/internal/ws/RealWebSocketTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/ws"
cp "/tests/okhttp/src/test/java/okhttp3/internal/ws/WebSocketHttpTest.kt" "okhttp/src/test/java/okhttp3/internal/ws/WebSocketHttpTest.kt"

# Recompile test sources after copying
./gradlew :okhttp:compileTestKotlin --no-daemon || true

# Run only the test classes for this PR
./gradlew :okhttp:test --tests "okhttp3.OkHttpClientTest" --no-daemon && \
./gradlew :okhttp:test --tests "okhttp3.internal.ws.RealWebSocketTest" --no-daemon && \
./gradlew :okhttp:test --tests "okhttp3.internal.ws.WebSocketHttpTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
