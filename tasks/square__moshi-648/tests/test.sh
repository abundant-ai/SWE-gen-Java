#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt"

# Rebuild main sources after applying fix.patch (for Oracle agent)
if [ -f /solution/fix.patch ]; then
  mvn install -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true
fi

# Run the GeneratedAdaptersTest in the kotlin/tests module
mvn test -pl kotlin/tests -Dtest="GeneratedAdaptersTest" -Dcheckstyle.skip -Dsurefire.timeout=120
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
