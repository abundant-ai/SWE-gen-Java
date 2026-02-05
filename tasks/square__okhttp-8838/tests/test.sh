#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-logging-interceptor/src/test/java/okhttp3/logging"
cp "/tests/okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.kt" "okhttp-logging-interceptor/src/test/java/okhttp3/logging/HttpLoggingInterceptorTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp-logging-interceptor/build/classes/kotlin/test
rm -rf okhttp/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :logging-interceptor:test --tests "okhttp3.logging.HttpLoggingInterceptorTest" \
  :okhttp:jvmTest --tests "okhttp3.RequestTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
