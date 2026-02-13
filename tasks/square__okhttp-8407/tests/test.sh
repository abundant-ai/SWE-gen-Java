#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/ResponseBodyJvmTest.kt" "okhttp/src/test/java/okhttp3/ResponseBodyJvmTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :okhttp:testClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test class from this PR (ResponseBodyJvmTest)
# Add timeout to prevent hanging on buggy code
timeout 300 ./gradlew :okhttp:test \
    --tests "okhttp3.ResponseBodyJvmTest" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
