#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/GeneratedAdaptersTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/GeneratedAdaptersTest.kt"
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/KotlinCodeGenTest.kt"

# Rebuild compiler first (so kapt uses the patched annotation processor),
# then rebuild integration-test (triggers kapt to regenerate adapters with the fixed compiler).
mvn install -pl kotlin-codegen/compiler -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true
mvn clean install -pl kotlin-codegen/integration-test -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true

# Run the specific test classes in the kotlin-codegen integration-test module
mvn test \
  -pl kotlin-codegen/integration-test \
  -Dtest="GeneratedAdaptersTest,KotlinCodeGenTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
