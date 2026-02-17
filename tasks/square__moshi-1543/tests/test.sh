#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi-kotlin-tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/moshi-kotlin-tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "moshi-kotlin-tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

# Run the specific test class that was modified in the PR
./gradlew :moshi-kotlin-tests:test --tests com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
