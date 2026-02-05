#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-android/src/androidTest/kotlin/okhttp3/android"
cp "/tests/okhttp-android/src/androidTest/kotlin/okhttp3/android/AndroidAsyncDnsTest.kt" "okhttp-android/src/androidTest/kotlin/okhttp3/android/AndroidAsyncDnsTest.kt"
mkdir -p "okhttp-coroutines/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp-coroutines/src/jvmTest/kotlin/okhttp3/SuspendCallTest.kt" "okhttp-coroutines/src/jvmTest/kotlin/okhttp3/SuspendCallTest.kt"
mkdir -p "okhttp-testing-support/src/main/kotlin/okhttp3"
cp "/tests/okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt" "okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt" "okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallHandshakeTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallHandshakeTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ConnectionReuseTest.kt" "okhttp/src/jvmTest/java/okhttp3/ConnectionReuseTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/FastFallbackTest.kt" "okhttp/src/jvmTest/java/okhttp3/FastFallbackTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt" "okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/JSSETest.kt" "okhttp/src/jvmTest/java/okhttp3/JSSETest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt" "okhttp/src/jvmTest/java/okhttp3/KotlinSourceModernTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/OkHttpClientTest.kt" "okhttp/src/jvmTest/java/okhttp3/OkHttpClientTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/OpenJSSETest.kt" "okhttp/src/jvmTest/java/okhttp3/OpenJSSETest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/RequestTest.kt" "okhttp/src/jvmTest/java/okhttp3/RequestTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt" "okhttp/src/jvmTest/java/okhttp3/ServerTruncatesRequestTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/SessionReuseTest.kt" "okhttp/src/jvmTest/java/okhttp3/SessionReuseTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/java/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/connection"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/connection/ConnectionPoolTest.kt" "okhttp/src/jvmTest/java/okhttp3/internal/connection/ConnectionPoolTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http/CancelTest.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http/CancelTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Compile test sources to ensure they're up-to-date after copying HEAD test files
./gradlew --no-daemon compileTestKotlin compileTestJava || true

# Run specific test classes using Gradle
# Note: TestValueFactory is not a test class, just a utility
./gradlew --no-daemon :okhttp:jvmTest \
  --tests "okhttp3.CacheCorruptionTest" \
  --tests "okhttp3.CallHandshakeTest" \
  --tests "okhttp3.CallKotlinTest" \
  --tests "okhttp3.CallTest" \
  --tests "okhttp3.ConnectionReuseTest" \
  --tests "okhttp3.FastFallbackTest" \
  --tests "okhttp3.InsecureForHostTest" \
  --tests "okhttp3.JSSETest" \
  --tests "okhttp3.KotlinSourceModernTest" \
  --tests "okhttp3.OkHttpClientTest" \
  --tests "okhttp3.OpenJSSETest" \
  --tests "okhttp3.RequestTest" \
  --tests "okhttp3.ServerTruncatesRequestTest" \
  --tests "okhttp3.SessionReuseTest" \
  --tests "okhttp3.URLConnectionTest" \
  --tests "okhttp3.internal.connection.ConnectionPoolTest" \
  --tests "okhttp3.internal.http.CancelTest" \
  --tests "okhttp3.internal.http2.HttpOverHttp2Test"

# Run coroutines tests separately (different module)
./gradlew --no-daemon :okhttp-coroutines:jvmTest \
  --tests "okhttp3.SuspendCallTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
