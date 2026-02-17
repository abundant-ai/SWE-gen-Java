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
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/MapJsonAdapterTest.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"

# Run tests in moshi module (MapJsonAdapterTest, MoshiTest)
mvn test -pl moshi -Dtest="MapJsonAdapterTest,MoshiTest" -Dcheckstyle.skip
moshi_status=$?

# Run tests in kotlin/tests module (KotlinJsonAdapterTest)
mvn test -pl kotlin/tests -Dtest="KotlinJsonAdapterTest" -Dcheckstyle.skip
kotlin_status=$?

test_status=0
if [ $moshi_status -ne 0 ] || [ $kotlin_status -ne 0 ]; then
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
