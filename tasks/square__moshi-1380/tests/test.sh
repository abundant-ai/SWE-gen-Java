#!/bin/bash

cd /app/src

# Use Java 11 for tests to avoid Java 7 target compatibility issues
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt" "kotlin/codegen/src/test/java/com/squareup/moshi/kotlin/codegen/JsonClassCodegenProcessorTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/KotlinExtensionsTest.kt" "moshi/src/test/java/com/squareup/moshi/KotlinExtensionsTest.kt"

# Run specific tests for this PR
./gradlew :kotlin:codegen:test --tests JsonClassCodegenProcessorTest --stacktrace 2>&1 | tee /tmp/codegen_test.log
codegen_status=${PIPESTATUS[0]}

./gradlew :kotlin:tests:test --tests GeneratedAdaptersTest --tests KotlinJsonAdapterTest --stacktrace
kotlin_tests_status=$?

./gradlew :moshi:test --tests KotlinExtensionsTest --stacktrace
moshi_status=$?

# Overall test status
if [ $codegen_status -eq 0 ] && [ $kotlin_tests_status -eq 0 ] && [ $moshi_status -eq 0 ]; then
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
