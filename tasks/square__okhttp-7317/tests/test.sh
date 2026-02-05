#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java"
mkdir -p "okhttp-android/src/androidTest/kotlin/okhttp3/android"
cp "/tests/okhttp-android/src/androidTest/kotlin/okhttp3/android/AndroidAsyncDnsTest.kt" "okhttp-android/src/androidTest/kotlin/okhttp3/android/AndroidAsyncDnsTest.kt"
mkdir -p "okhttp-logging-interceptor/src/test/java/okhttp3/logging"
cp "/tests/okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.java" "okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.java"
mkdir -p "okhttp-logging-interceptor/src/test/java/okhttp3/logging"
cp "/tests/okhttp-logging-interceptor/src/test/java/okhttp3/logging/LoggingEventListenerTest.java" "okhttp-logging-interceptor/src/test/java/okhttp3/logging/LoggingEventListenerTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt" "okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheTest.java" "okhttp/src/jvmTest/java/okhttp3/CacheTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallHandshakeTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallHandshakeTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ConnectionCoalescingTest.java" "okhttp/src/jvmTest/java/okhttp3/ConnectionCoalescingTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ConnectionReuseTest.kt" "okhttp/src/jvmTest/java/okhttp3/ConnectionReuseTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/DuplexTest.java" "okhttp/src/jvmTest/java/okhttp3/DuplexTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/EventListenerTest.java" "okhttp/src/jvmTest/java/okhttp3/EventListenerTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt" "okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/JSSETest.kt" "okhttp/src/jvmTest/java/okhttp3/JSSETest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt" "okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/OpenJSSETest.kt" "okhttp/src/jvmTest/java/okhttp3/OpenJSSETest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/SessionReuseTest.kt" "okhttp/src/jvmTest/java/okhttp3/SessionReuseTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/SocketChannelTest.kt" "okhttp/src/jvmTest/java/okhttp3/SocketChannelTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http/CancelTest.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http/CancelTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/tls"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/tls/CertificatePinnerChainValidationTest.java" "okhttp/src/jvmTest/java/okhttp3/internal/tls/CertificatePinnerChainValidationTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/tls"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/tls/ClientAuthTest.java" "okhttp/src/jvmTest/java/okhttp3/internal/tls/ClientAuthTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/ws"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/ws/WebSocketHttpTest.java" "okhttp/src/jvmTest/java/okhttp3/internal/ws/WebSocketHttpTest.java"

# Compile test sources to ensure they're up-to-date after copying HEAD test files
./gradlew --no-daemon compileTestKotlin compileTestJava || true

# Run specific test classes using Gradle
# Note: Only running okhttp:jvmTest and logging-interceptor tests as mockwebserver tests have module configuration issues
./gradlew --no-daemon :okhttp:jvmTest \
  --tests "okhttp3.CacheCorruptionTest" \
  --tests "okhttp3.CacheTest" \
  --tests "okhttp3.CallHandshakeTest" \
  --tests "okhttp3.CallKotlinTest" \
  --tests "okhttp3.CallTest" \
  --tests "okhttp3.ConnectionCoalescingTest" \
  --tests "okhttp3.ConnectionReuseTest" \
  --tests "okhttp3.DuplexTest" \
  --tests "okhttp3.EventListenerTest" \
  --tests "okhttp3.InsecureForHostTest" \
  --tests "okhttp3.JSSETest" \
  --tests "okhttp3.KotlinSourceModernTest" \
  --tests "okhttp3.OpenJSSETest" \
  --tests "okhttp3.ServerTruncatesRequestTest" \
  --tests "okhttp3.SessionReuseTest" \
  --tests "okhttp3.SocketChannelTest" \
  --tests "okhttp3.URLConnectionTest" \
  --tests "okhttp3.internal.http.CancelTest" \
  --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  --tests "okhttp3.internal.tls.CertificatePinnerChainValidationTest" \
  --tests "okhttp3.internal.tls.ClientAuthTest" \
  --tests "okhttp3.internal.ws.WebSocketHttpTest"

test_status=$?

# Also run logging interceptor tests
if [ $test_status -eq 0 ]; then
  ./gradlew --no-daemon :logging-interceptor:test \
    --tests "okhttp3.logging.HttpLoggingInterceptorTest" \
    --tests "okhttp3.logging.LoggingEventListenerTest"
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
