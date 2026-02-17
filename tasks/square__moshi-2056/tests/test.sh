#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi-adapters/src/test/java/com/squareup/moshi/adapters"
cp "/tests/moshi-adapters/src/test/java/com/squareup/moshi/adapters/PolymorphicJsonAdapterFactoryTest.java" "moshi-adapters/src/test/java/com/squareup/moshi/adapters/PolymorphicJsonAdapterFactoryTest.java"

# Run the specific test class that was modified in the PR
./gradlew :moshi-adapters:test --tests com.squareup.moshi.adapters.PolymorphicJsonAdapterFactoryTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
