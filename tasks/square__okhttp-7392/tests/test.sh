#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionLifecycleTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionLifecycleTest.kt"
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionMultipleInstancesTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionMultipleInstancesTest.kt"
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionMultipleTestsTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/ExtensionMultipleTestsTest.kt"
mkdir -p "okhttp-coroutines/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp-coroutines/src/jvmTest/kotlin/okhttp3/SuspendCallTest.kt" "okhttp-coroutines/src/jvmTest/kotlin/okhttp3/SuspendCallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/BouncyCastleTest.kt" "okhttp/src/jvmTest/java/okhttp3/BouncyCastleTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt" "okhttp/src/jvmTest/java/okhttp3/CacheCorruptionTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CacheTest.java" "okhttp/src/jvmTest/java/okhttp3/CacheTest.java"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallKotlinTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/CallTest.kt" "okhttp/src/jvmTest/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt" "okhttp/src/jvmTest/java/okhttp3/InsecureForHostTest.kt"
mkdir -p "okhttp/src/jvmTest/java/okhttp3"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/JSSETest.kt" "okhttp/src/jvmTest/java/okhttp3/JSSETest.kt"
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

# Run specific test classes
./gradlew --no-daemon \
  :mockwebserver-junit5:test --tests "mockwebserver3.junit5.internal.ExtensionLifecycleTest" \
  :mockwebserver-junit5:test --tests "mockwebserver3.junit5.internal.ExtensionMultipleInstancesTest" \
  :mockwebserver-junit5:test --tests "mockwebserver3.junit5.internal.ExtensionMultipleTestsTest" \
  :okhttp-coroutines:jvmTest --tests "okhttp3.SuspendCallTest" \
  :okhttp:jvmTest --tests "okhttp3.BouncyCastleTest" \
  :okhttp:jvmTest --tests "okhttp3.CacheCorruptionTest" \
  :okhttp:jvmTest --tests "okhttp3.CacheTest" \
  :okhttp:jvmTest --tests "okhttp3.CallKotlinTest" \
  :okhttp:jvmTest --tests "okhttp3.CallTest" \
  :okhttp:jvmTest --tests "okhttp3.InsecureForHostTest" \
  :okhttp:jvmTest --tests "okhttp3.JSSETest" \
  :okhttp:jvmTest --tests "okhttp3.OpenJSSETest" \
  :okhttp:jvmTest --tests "okhttp3.ServerTruncatesRequestTest" \
  :okhttp:jvmTest --tests "okhttp3.SessionReuseTest" \
  :okhttp:jvmTest --tests "okhttp3.SocketChannelTest" \
  :okhttp:jvmTest --tests "okhttp3.URLConnectionTest"

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
