#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/BufferedSinkJsonWriterTest.java" "moshi/src/test/java/com/squareup/moshi/BufferedSinkJsonWriterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/BufferedSourceJsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/BufferedSourceJsonReaderTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"

# Remove test files that reference newParameterizedTypeWithOwner (absent in buggy BASE state)
# to prevent compilation failure when running the targeted tests.
rm -f moshi/src/test/java/com/squareup/moshi/AdapterMethodsTest.java
rm -f moshi/src/test/java/com/squareup/moshi/TypesTest.java

# Run the specific test classes from this PR in the moshi module
mvn test \
  -pl moshi \
  -Dtest="BufferedSinkJsonWriterTest,BufferedSourceJsonReaderTest,MapJsonAdapterTest,MoshiTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
