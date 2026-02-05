#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserverwrapper/src/test/java/okhttp3/mockwebserverwrapper"
cp "/tests/mockwebserverwrapper/src/test/java/okhttp3/mockwebserverwrapper/MockWebServerTest.java" "mockwebserverwrapper/src/test/java/okhttp3/mockwebserverwrapper/MockWebServerTest.java"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserverwrapper/build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :mockwebserverwrapper:test --tests "okhttp3.mockwebserverwrapper.MockWebServerTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
