#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/DataClassesTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/DataClassesTest.kt"
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt"

# Rebuild compiler and integration-test after restoring HEAD test files
mvn install -pl kotlin-codegen/compiler,kotlin-codegen/integration-test -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true

# Run DataClassesTest and KotlinCodeGenTest in the kotlin-codegen/integration-test module
mvn test \
  -pl kotlin-codegen/integration-test \
  -Dtest="DataClassesTest,KotlinCodeGenTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
