#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/CompilerTest.kt" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/CompilerTest.kt"
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/KotlinCompilerCall.kt" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/KotlinCompilerCall.kt"
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/KotlinCompilerResult.kt" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/KotlinCompilerResult.kt"

# Rebuild compiler after restoring HEAD test files (picks up restored dependencies and test classes)
mvn install -pl kotlin-codegen/compiler -am -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true

# Run CompilerTest in the kotlin-codegen/compiler module
mvn test \
  -pl kotlin-codegen/compiler \
  -Dtest="CompilerTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
