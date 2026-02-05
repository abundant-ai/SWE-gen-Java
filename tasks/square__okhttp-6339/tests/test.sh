#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/InjectedConstructorTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/InjectedConstructorTest.kt"
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/InjectedParameterTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/InjectedParameterTest.kt"
mkdir -p "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal"
cp "/tests/mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/MultipleServersTest.kt" "mockwebserver-junit5/src/test/java/mockwebserver3/junit5/internal/MultipleServersTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver-junit5/build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :mockwebserver-junit5:test --tests "mockwebserver3.junit5.internal.InjectedConstructorTest" \
  --tests "mockwebserver3.junit5.internal.InjectedParameterTest" \
  --tests "mockwebserver3.junit5.internal.MultipleServersTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
