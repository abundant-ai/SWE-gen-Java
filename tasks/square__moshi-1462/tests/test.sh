#!/bin/bash

cd /app/src

# Clean and rebuild main code after fix.patch is applied (Oracle agent applies this before running tests)
./gradlew :moshi:clean :moshi:compileJava :moshi:compileKotlin --stacktrace

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/MoshiTest.java" "moshi/src/test/java/com/squareup/moshi/MoshiTest.java"

# Run the specific test class that was modified in the PR
./gradlew :moshi:test --tests com.squareup.moshi.MoshiTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
