#!/bin/bash

cd /app/src

# Use Java 11 for tests to avoid Java 7 target compatibility issues
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java"

# Run specific tests for this PR
./gradlew :moshi:test --tests JsonReaderTest --tests JsonWriterTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
