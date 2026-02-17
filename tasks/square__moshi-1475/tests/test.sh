#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java" "moshi/src/test/java/com/squareup/moshi/JsonAdapterTest.java"

# Run the specific test class that was modified in the PR
./gradlew :moshi:test --tests com.squareup.moshi.JsonAdapterTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
