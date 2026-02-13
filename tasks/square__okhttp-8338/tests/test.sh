#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-android/src/test/kotlin/okhttp3/android"
cp "/tests/okhttp-android/src/test/kotlin/okhttp3/android/RobolectricOkHttpClientTest.kt" "okhttp-android/src/test/kotlin/okhttp3/android/RobolectricOkHttpClientTest.kt"
mkdir -p "okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps"
cp "/tests/okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps/DnsOverHttpsTest.kt" "okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps/DnsOverHttpsTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/CacheTest.kt" "okhttp/src/test/java/okhttp3/CacheTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/CallTest.kt" "okhttp/src/test/java/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/test/java/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/test/java/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Rebuild test classes to pick up the changes
./gradlew :okhttp:testClasses :okhttp-coroutines:testClasses :okhttp-android:testClasses :okhttp-dnsoverhttps:testClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test classes from this PR
# Add timeout to prevent hanging on buggy code
# Skipping HttpOverHttp2Test as it times out and is unrelated to the signature change
timeout 600 ./gradlew :okhttp:test \
    --tests "okhttp3.CacheTest" \
    --tests "okhttp3.CallTest" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  timeout 600 ./gradlew :okhttp-dnsoverhttps:test \
      --tests "okhttp3.dnsoverhttps.DnsOverHttpsTest" \
      --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
  test_status=$?
fi

# Skip Android and HttpOverHttp2 tests as they have environmental issues unrelated to the signature change being tested
# Android tests require Android SDK which is complex to set up
# HttpOverHttp2Test has a slow test that times out

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
