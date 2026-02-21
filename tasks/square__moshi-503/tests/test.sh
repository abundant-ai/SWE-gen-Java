#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
# Also copy companion files that the base state modified (skipName tests, getFieldJsonQualifierAnnotations tests)
# to ensure compatibility with the fixed main sources
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonUtf8WriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonUtf8WriterTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonValueWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonValueWriterTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java" "moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonUtf8ReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonUtf8ReaderTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/TypesTest.java" "moshi/src/test/java/com/squareup/moshi/TypesTest.java"

# Rebuild main sources to pick up any patches applied (clean to force recompilation)
mvn clean install -pl moshi -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true

# Run the specific test classes in the moshi module
mvn test \
  -pl moshi \
  -Dtest="JsonUtf8WriterTest,JsonValueWriterTest,PromoteNameToValueTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
