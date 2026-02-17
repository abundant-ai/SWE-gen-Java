#!/bin/bash

cd /app/src

# Switch to Java 17 for running tests (needed for records-tests which requires Java 16+)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/tests"
cp "/tests/kotlin/tests/build.gradle.kts" "kotlin/tests/build.gradle.kts"
mkdir -p "moshi/records-tests/src/test/java/com/squareup/moshi/records"
cp "/tests/moshi/records-tests/src/test/java/com/squareup/moshi/records/RecordsTest.java" "moshi/records-tests/src/test/java/com/squareup/moshi/records/RecordsTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonValueReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonValueReaderTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonValueWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonValueWriterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java"

# Run specific tests for this PR
./gradlew :moshi:test --tests JsonAdapterTest --tests JsonReaderTest --tests JsonWriterTest --tests JsonValueReaderTest --tests JsonValueWriterTest --stacktrace
moshi_status=$?

./gradlew :moshi:records-tests:test --tests RecordsTest --stacktrace
records_status=$?

# Overall test status
if [ $moshi_status -eq 0 ] && [ $records_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
