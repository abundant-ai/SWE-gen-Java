#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.kt" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.kt"
mkdir -p "okhttp-coroutines/src/test/kotlin/okhttp3/coroutines"
cp "/tests/okhttp-coroutines/src/test/kotlin/okhttp3/coroutines/ExecuteAsyncTest.kt" "okhttp-coroutines/src/test/kotlin/okhttp3/coroutines/ExecuteAsyncTest.kt"
mkdir -p "okhttp-logging-interceptor/src/test/java/okhttp3/logging"
cp "/tests/okhttp-logging-interceptor/src/test/java/okhttp3/logging/LoggingEventListenerTest.kt" "okhttp-logging-interceptor/src/test/java/okhttp3/logging/LoggingEventListenerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CacheTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CacheTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CallKotlinTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CallKotlinTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/ConnectionListenerTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/ConnectionListenerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/ConnectionReuseTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/ConnectionReuseTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/EventListenerTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/EventListenerTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/FastFallbackTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/FastFallbackTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/InterceptorTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/InterceptorTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/RouteFailureTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/RouteFailureTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/ServerTruncatesRequestTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/TrailersTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/TrailersTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/tls"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/tls/CertificatePinnerChainValidationTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/tls/CertificatePinnerChainValidationTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/ws"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/ws/WebSocketHttpTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/ws/WebSocketHttpTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/jvmTest
rm -rf okhttp-coroutines/build/classes/kotlin/test
rm -rf okhttp-logging-interceptor/build/classes/kotlin/test
rm -rf mockwebserver/build/classes/kotlin/test
rm -rf build/classes/kotlin/jvmTest

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :mockwebserver3:test --tests "mockwebserver3.MockWebServerTest" \
  :okhttp-coroutines:test --tests "okhttp3.coroutines.ExecuteAsyncTest" \
  :logging-interceptor:test --tests "okhttp3.logging.LoggingEventListenerTest" \
  :okhttp:jvmTest --tests "okhttp3.CacheTest" \
  :okhttp:jvmTest --tests "okhttp3.CallKotlinTest" \
  :okhttp:jvmTest --tests "okhttp3.CallTest" \
  :okhttp:jvmTest --tests "okhttp3.ConnectionListenerTest" \
  :okhttp:jvmTest --tests "okhttp3.ConnectionReuseTest" \
  :okhttp:jvmTest --tests "okhttp3.EventListenerTest" \
  :okhttp:jvmTest --tests "okhttp3.FastFallbackTest" \
  :okhttp:jvmTest --tests "okhttp3.InterceptorTest" \
  :okhttp:jvmTest --tests "okhttp3.RouteFailureTest" \
  :okhttp:jvmTest --tests "okhttp3.ServerTruncatesRequestTest" \
  :okhttp:jvmTest --tests "okhttp3.TrailersTest" \
  :okhttp:jvmTest --tests "okhttp3.URLConnectionTest" \
  :okhttp:jvmTest --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  :okhttp:jvmTest --tests "okhttp3.internal.tls.CertificatePinnerChainValidationTest" \
  :okhttp:jvmTest --tests "okhttp3.internal.ws.WebSocketHttpTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
