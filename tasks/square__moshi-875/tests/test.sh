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
mkdir -p "kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"
mkdir -p "kotlin/tests"
cp "/tests/kotlin/tests/pom.xml" "kotlin/tests/pom.xml"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codgen/GeneratedAdaptersTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java"

# Run tests in moshi module (JsonAdapterTest)
cd /app/src/moshi
mvn test -Dtest=JsonAdapterTest -Dcheckstyle.skip
moshi_status=$?

# Run tests in kotlin/tests module (GeneratedAdaptersTest and KotlinJsonAdapterTest)
# Note: kotlin/reflect/src/main/test/java/.../KotlinJsonAdapterTest.kt is a non-standard
# test source location and is not directly runnable via Maven in the kotlin/reflect module.
# The relevant tests run in kotlin/tests module.
cd /app/src/kotlin/tests
mvn test -Dtest="GeneratedAdaptersTest,KotlinJsonAdapterTest" -Dcheckstyle.skip
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
