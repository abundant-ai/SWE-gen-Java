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
mkdir -p "adapters/src/test/java/com/squareup/moshi/adapters"
cp "/tests/adapters/src/test/java/com/squareup/moshi/adapters/Rfc3339DateJsonAdapterTest.java" "adapters/src/test/java/com/squareup/moshi/adapters/Rfc3339DateJsonAdapterTest.java"

# Run specific tests for this PR
# Rfc3339DateJsonAdapterTest is in the adapters module
cd adapters
mvn clean test -Dtest=Rfc3339DateJsonAdapterTest -Dcheckstyle.skip
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
