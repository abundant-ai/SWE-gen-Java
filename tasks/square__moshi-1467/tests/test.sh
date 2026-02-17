#!/bin/bash

cd /app/src

# Clean and rebuild main code after fix.patch is applied (Oracle agent applies this before running tests)
./gradlew :moshi:clean :moshi:compileJava :moshi:compileKotlin --stacktrace

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/AdapterMethodsTest.java" "moshi/src/test/java/com/squareup/moshi/AdapterMethodsTest.java"
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonQualifiersTest.java" "moshi/src/test/java/com/squareup/moshi/JsonQualifiersTest.java"

# Run the specific test classes that were modified in the PR
./gradlew :moshi:test --tests com.squareup.moshi.AdapterMethodsTest --tests com.squareup.moshi.JsonQualifiersTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
