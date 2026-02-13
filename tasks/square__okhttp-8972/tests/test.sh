#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/RecordedRequestTest.kt" "mockwebserver/src/test/java/mockwebserver3/RecordedRequestTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :mockwebserver3:testClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test class from this PR
./gradlew :mockwebserver3:test \
    --tests mockwebserver3.RecordedRequestTest \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
