#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/src/test/java/com/squareup/moshi"
cp "/tests/kotlin/src/test/java/com/squareup/moshi/KotlinJsonAdapterTest.kt" "kotlin/src/test/java/com/squareup/moshi/KotlinJsonAdapterTest.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"

# Run the specific test classes from this PR in the moshi and kotlin modules
mvn test \
  -pl moshi,kotlin \
  -Dtest="MoshiTest,KotlinJsonAdapterTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
