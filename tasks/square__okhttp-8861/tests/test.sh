#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt" "mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt"
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.kt" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/ConnectionListenerTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/ConnectionListenerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/EventListenerTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/EventListenerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/RouteFailureTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/RouteFailureTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/WholeOperationTimeoutTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/WholeOperationTimeoutTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver/build/classes/kotlin/test
rm -rf okhttp/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :mockwebserver3:test --tests "mockwebserver3.MockResponseSniTest" \
  :mockwebserver3:test --tests "mockwebserver3.MockWebServerTest" \
  :okhttp:jvmTest --tests "okhttp3.CallTest" \
  :okhttp:jvmTest --tests "okhttp3.ConnectionListenerTest" \
  :okhttp:jvmTest --tests "okhttp3.EventListenerTest" \
  :okhttp:jvmTest --tests "okhttp3.RouteFailureTest" \
  :okhttp:jvmTest --tests "okhttp3.URLConnectionTest" \
  :okhttp:jvmTest --tests "okhttp3.WholeOperationTimeoutTest" \
  :okhttp:jvmTest --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
