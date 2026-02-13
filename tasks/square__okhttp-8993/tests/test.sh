#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-logging-interceptor/src/test/java/okhttp3/logging"
cp "/tests/okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.kt" "okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/DuplexTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/DuplexTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :logging-interceptor:testClasses :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test classes from this PR
./gradlew :logging-interceptor:test \
    --tests okhttp3.logging.HttpLoggingInterceptorTest \
    :okhttp:jvmTest \
    --tests okhttp3.DuplexTest \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
