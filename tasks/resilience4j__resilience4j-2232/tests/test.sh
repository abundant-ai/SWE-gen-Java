#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead/internal"
cp "/tests/resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead/internal/SemaphoreBulkheadTest.java" "resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead/internal/SemaphoreBulkheadTest.java"

# Run the specific test class for the bulkhead module
./gradlew :resilience4j-bulkhead:test \
          --tests io.github.resilience4j.bulkhead.internal.SemaphoreBulkheadTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
