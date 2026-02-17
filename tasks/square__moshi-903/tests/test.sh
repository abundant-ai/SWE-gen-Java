#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Rebuild after applying fix.patch (for Oracle agent)
if [ -f /solution/fix.patch ]; then
  mvn install -DskipTests -Dcheckstyle.skip > /dev/null 2>&1 || true
  # TypeResolverTest.kt only exists in the buggy state (added by bug.patch);
  # in the fixed state TypeResolver.kt is removed, so remove the test too.
  rm -f "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/TypeResolverTest.kt"
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt" "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt"

# Run specific tests for this PR
# JsonClassCodegenProcessorTest is in the kotlin/codegen module
cd kotlin/codegen
mvn clean test -Dtest=JsonClassCodegenProcessorTest -Dcheckstyle.skip
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
