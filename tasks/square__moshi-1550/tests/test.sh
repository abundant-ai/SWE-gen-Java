#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/tests"
cp "/tests/kotlin/tests/build.gradle.kts" "kotlin/tests/build.gradle.kts"
mkdir -p "kotlin/tests/codegen-only"
cp "/tests/kotlin/tests/codegen-only/build.gradle.kts" "kotlin/tests/codegen-only/build.gradle.kts"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

# Run the specific test class that was modified in the PR
./gradlew :kotlin:tests:test --tests com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterTest --stacktrace -PkotlinTestMode=REFLECT
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
