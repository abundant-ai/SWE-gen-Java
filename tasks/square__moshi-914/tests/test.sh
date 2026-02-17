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
mkdir -p "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt" "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

# Run specific tests for this PR
# JsonClassCodegenProcessorTest is in kotlin/codegen, KotlinJsonAdapterTest is in kotlin/tests
# Use clean test to ensure stale compiled classes are removed before recompiling
cd kotlin/codegen
mvn clean test -Dtest=JsonClassCodegenProcessorTest -Dcheckstyle.skip
codegen_status=$?

cd /app/src/kotlin/tests
mvn clean test -Dtest=KotlinJsonAdapterTest -Dcheckstyle.skip
tests_status=$?

if [ $codegen_status -eq 0 ] && [ $tests_status -eq 0 ]; then
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
