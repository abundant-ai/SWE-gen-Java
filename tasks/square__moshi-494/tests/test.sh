#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt"
mkdir -p "kotlin/src/test/java/com/squareup/moshi/kotlin"
cp "/tests/kotlin/src/test/java/com/squareup/moshi/kotlin/KotlinJsonAdapterTest.kt" "kotlin/src/test/java/com/squareup/moshi/kotlin/KotlinJsonAdapterTest.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/AdapterMethodsTest.java" "moshi/src/test/java/com/squareup/moshi/AdapterMethodsTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"

# Rebuild main sources to pick up any patches applied (clean to force recompilation)
mvn clean install -pl kotlin-codegen/integration-test,kotlin,moshi -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true

# Run the specific test classes across relevant modules
mvn test \
  -pl kotlin-codegen/integration-test,kotlin,moshi \
  -Dtest="KotlinCodeGenTest,KotlinJsonAdapterTest,AdapterMethodsTest,MoshiTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
