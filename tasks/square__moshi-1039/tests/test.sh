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
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt"

# Run specific tests for this PR (tests are in kotlin/tests module)
cd kotlin/tests
mvn test -Dtest=GeneratedAdaptersTest -Dcheckstyle.skip
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
