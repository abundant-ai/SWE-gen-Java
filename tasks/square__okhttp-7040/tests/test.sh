#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/java/okhttp3/internal/connection"
cp "/tests/okhttp/src/jvmTest/java/okhttp3/internal/connection/InetAddressOrderTest.kt" "okhttp/src/jvmTest/java/okhttp3/internal/connection/InetAddressOrderTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/test

# Run the specific test class for this PR
# Note: Using -x to skip compileTestJava because ConnectionSpecSelectorTest.java references
# an internal Kotlin class and won't compile, but we only need to run the Kotlin test
./gradlew --no-daemon \
  :okhttp:jvmTest --tests "okhttp3.internal.connection.InetAddressOrderTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false \
  -x compileTestJava
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
