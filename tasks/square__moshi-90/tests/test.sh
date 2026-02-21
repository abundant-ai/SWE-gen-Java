#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/ClassJsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/ClassJsonAdapterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonWriterPathTest.java" "moshi/src/test/java/com/squareup/moshi/JsonWriterPathTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java" "moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/TestUtil.java" "moshi/src/test/java/com/squareup/moshi/TestUtil.java"

# Run the specific test classes from this PR in the moshi module
mvn test \
  -pl moshi \
  -Dtest="ClassJsonAdapterTest,JsonReaderTest,JsonWriterPathTest,JsonWriterTest,MapJsonAdapterTest,PromoteNameToValueTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
