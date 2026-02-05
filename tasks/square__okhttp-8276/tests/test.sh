#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-testing-support/src/main/kotlin/okhttp3"
cp "/tests/okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt" "okhttp-testing-support/src/main/kotlin/okhttp3/TestValueFactory.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/connection"
cp "/tests/okhttp/src/test/java/okhttp3/internal/connection/RouteSelectorTest.kt" "okhttp/src/test/java/okhttp3/internal/connection/RouteSelectorTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :okhttp:test --tests "okhttp3.internal.connection.RouteSelectorTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
