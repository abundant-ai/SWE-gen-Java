#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Rebuild after applying fix.patch (for Oracle agent)
if [ -f /solution/fix.patch ]; then
  mvn install -DskipTests -Dcheckstyle.skip > /dev/null 2>&1 || true
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonWriterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java" "moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java"

# Run specific tests for this PR
# JsonWriterTest and PromoteNameToValueTest are in the moshi module
# Use clean test to ensure stale compiled classes are removed before recompiling
cd moshi
mvn clean test -Dtest=JsonWriterTest,PromoteNameToValueTest -Dcheckstyle.skip
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
