#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-testing-support/src/main/kotlin/okhttp3"
cp "/tests/okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt" "okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/connection"
cp "/tests/okhttp/src/test/java/okhttp3/internal/connection/ConnectionPoolTest.kt" "okhttp/src/test/java/okhttp3/internal/connection/ConnectionPoolTest.kt"

# Rebuild testing-support and test classes to pick up the changes
./gradlew :okhttp-testing-support:classes :okhttp:testClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test classes from this PR
# Add timeout to prevent hanging on buggy code
timeout 600 ./gradlew :okhttp:test \
    --tests "okhttp3.internal.connection.ConnectionPoolTest" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
