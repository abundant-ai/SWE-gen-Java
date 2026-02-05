#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/StartStopTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/StartStopTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver-junit5/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :mockwebserver3-junit5:test --tests "mockwebserver3.junit5.StartStopTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
