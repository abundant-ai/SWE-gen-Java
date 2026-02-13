#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/MultipartReaderTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/MultipartReaderTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test classes from this PR using wildcard pattern
# Add timeout to prevent hanging on buggy code
timeout 300 ./gradlew :okhttp:jvmTest \
    --tests "*MultipartReaderTest*" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
