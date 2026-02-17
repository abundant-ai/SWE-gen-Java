#!/bin/bash

cd /app/src

# Use Java 11 for tests to avoid Java 7 target compatibility issues
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt" "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt"

# Run specific test for this PR
./gradlew :kotlin:codegen:test --tests JsonClassCodegenProcessorTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
