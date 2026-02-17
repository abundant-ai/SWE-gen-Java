#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi/internal"
cp "/tests/moshi/src/test/java/com/squareup/moshi/internal/KotlinReflectTypesTest.kt" "moshi/src/test/java/com/squareup/moshi/internal/KotlinReflectTypesTest.kt"

# Run the specific test classes that were modified in the PR
./gradlew :moshi:test --tests com.squareup.moshi.MoshiTest --tests com.squareup.moshi.internal.KotlinReflectTypesTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
