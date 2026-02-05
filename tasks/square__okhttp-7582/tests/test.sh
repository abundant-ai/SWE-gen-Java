#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java"
mkdir -p "okhttp-sse/src/test/java/okhttp3/sse/internal"
cp "/tests/okhttp-sse/src/test/java/okhttp3/sse/internal/EventSourceHttpTest.java" "okhttp-sse/src/test/java/okhttp3/sse/internal/EventSourceHttpTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheTest.java" "okhttp/src/jvmTest/java/okhttp3/CacheTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CookiesTest.java" "okhttp/src/jvmTest/java/okhttp3/CookiesTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/InterceptorTest.java" "okhttp/src/jvmTest/java/okhttp3/InterceptorTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/ws"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/ws/WebSocketHttpTest.java" "okhttp/src/jvmTest/java/okhttp3/internal/ws/WebSocketHttpTest.java"
mkdir -p "samples/compare/src/test/kotlin/okhttp3/compare"
cp "/tests/samples/compare/src/test/kotlin/okhttp3/compare/ApacheHttpClientTest.kt" "samples/compare/src/test/kotlin/okhttp3/compare/ApacheHttpClientTest.kt"
mkdir -p "samples/compare/src/test/kotlin/okhttp3/compare"
cp "/tests/samples/compare/src/test/kotlin/okhttp3/compare/JavaHttpClientTest.kt" "samples/compare/src/test/kotlin/okhttp3/compare/JavaHttpClientTest.kt"
mkdir -p "samples/compare/src/test/kotlin/okhttp3/compare"
cp "/tests/samples/compare/src/test/kotlin/okhttp3/compare/JettyHttpClientTest.kt" "samples/compare/src/test/kotlin/okhttp3/compare/JettyHttpClientTest.kt"
mkdir -p "samples/compare/src/test/kotlin/okhttp3/compare"
cp "/tests/samples/compare/src/test/kotlin/okhttp3/compare/OkHttpClientTest.kt" "samples/compare/src/test/kotlin/okhttp3/compare/OkHttpClientTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver/build/classes/kotlin/test
rm -rf okhttp/build/classes/kotlin/test
rm -rf okhttp-sse/build/classes/kotlin/test
rm -rf okhttp-testing-support/build/classes/kotlin/test
rm -rf samples/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :mockwebserver3:test --tests "mockwebserver3.MockWebServerTest" \
  :okhttp-sse:test --tests "okhttp3.sse.internal.EventSourceHttpTest" \
  :okhttp:jvmTest --tests "okhttp3.CacheTest" \
  :okhttp:jvmTest --tests "okhttp3.CallTest" \
  :okhttp:jvmTest --tests "okhttp3.CookiesTest" \
  :okhttp:jvmTest --tests "okhttp3.InterceptorTest" \
  :okhttp:jvmTest --tests "okhttp3.URLConnectionTest" \
  :okhttp:jvmTest --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  :okhttp:jvmTest --tests "okhttp3.internal.ws.WebSocketHttpTest" \
  :samples:compare:test --tests "okhttp3.compare.ApacheHttpClientTest" \
  :samples:compare:test --tests "okhttp3.compare.JavaHttpClientTest" \
  :samples:compare:test --tests "okhttp3.compare.JettyHttpClientTest" \
  :samples:compare:test --tests "okhttp3.compare.OkHttpClientTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
