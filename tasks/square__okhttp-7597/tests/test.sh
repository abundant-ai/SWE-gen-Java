#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt" "mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver/build/classes/kotlin/test
rm -rf okhttp-testing-support/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :mockwebserver3:test --tests "mockwebserver3.MockResponseSniTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
