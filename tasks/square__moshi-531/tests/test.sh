#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/CompilerTest.kt" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/CompilerTest.kt"
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/JavaSuperclass.java" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/JavaSuperclass.java"
mkdir -p "kotlin-codegen/compiler/src/test/java/com/squareup/moshi"
cp "/tests/kotlin-codegen/compiler/src/test/java/com/squareup/moshi/TypeResolverTest.kt" "kotlin-codegen/compiler/src/test/java/com/squareup/moshi/TypeResolverTest.kt"
mkdir -p "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi"
cp "/tests/kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/GeneratedAdaptersTest.kt" "kotlin-codegen/integration-test/src/test/kotlin/com/squareup/moshi/GeneratedAdaptersTest.kt"
mkdir -p "kotlin/src/test/java/com/squareup/moshi/kotlin"
cp "/tests/kotlin/src/test/java/com/squareup/moshi/kotlin/KotlinJsonAdapterTest.kt" "kotlin/src/test/java/com/squareup/moshi/kotlin/KotlinJsonAdapterTest.kt"

# Rebuild main sources after applying fix.patch (for Oracle agent)
if [ -f /solution/fix.patch ]; then
  mvn install -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true
fi

# Run the specific test classes across the relevant modules
mvn test -pl kotlin-codegen/compiler,kotlin-codegen/integration-test,kotlin \
  -Dtest="CompilerTest,TypeResolverTest,GeneratedAdaptersTest,KotlinJsonAdapterTest" \
  -Dcheckstyle.skip -Dsurefire.timeout=300
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
