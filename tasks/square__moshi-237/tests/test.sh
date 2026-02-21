#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/TypesTest.java" "moshi/src/test/java/com/squareup/moshi/TypesTest.java"

# Remove test files that reference APIs not present in the fixed state.
# bug.patch added serializeNulls() and promoteValueToName() APIs that are not restored
# by fix.patch, causing compilation failures in these files.
rm -f moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java
rm -f moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java
rm -f moshi/src/test/java/com/squareup/moshi/PromoteNameToValueTest.java

# Run the specific test class from this PR in the moshi module
mvn test \
  -pl moshi \
  -Dtest="TypesTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
