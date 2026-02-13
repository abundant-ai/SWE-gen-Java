#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http/ThreadInterruptTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http/ThreadInterruptTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :logging-interceptor:testClasses :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test class from this PR
./gradlew :okhttp:jvmTest \
    --tests okhttp3.internal.http.ThreadInterruptTest \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
