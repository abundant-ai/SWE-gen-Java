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
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/TypesTest.java" "moshi/src/test/java/com/squareup/moshi/TypesTest.java"

# Run tests in moshi module (JsonAdapterTest and TypesTest)
cd /app/src/moshi
mvn test -Dtest="JsonAdapterTest,TypesTest" -Dcheckstyle.skip
moshi_status=$?

# Run tests in kotlin/tests module (GeneratedAdaptersTest and GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter)
cd /app/src/kotlin/tests
mvn test -Dtest="GeneratedAdaptersTest,GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter" -Dcheckstyle.skip
tests_status=$?

# Overall status: all must pass
if [ $moshi_status -eq 0 ] && [ $tests_status -eq 0 ]; then
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
