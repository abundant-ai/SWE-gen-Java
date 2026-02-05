#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 2g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http/HttpUpgradesTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http/HttpUpgradesTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/ws"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/ws/RealWebSocketTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/ws/RealWebSocketTest.kt"

# Run specific test classes for this PR
./gradlew --no-daemon :okhttp:jvmTest --tests okhttp3.internal.http.HttpUpgradesTest --tests okhttp3.internal.ws.RealWebSocketTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
