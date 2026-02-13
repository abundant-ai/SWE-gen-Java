#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-all/src/test/java/io/github/resilience4j/decorators"
cp "/tests/resilience4j-all/src/test/java/io/github/resilience4j/decorators/DecoratorsTest.java" "resilience4j-all/src/test/java/io/github/resilience4j/decorators/DecoratorsTest.java"
mkdir -p "resilience4j-retry/src/test/java/io/github/resilience4j/retry/internal"
cp "/tests/resilience4j-retry/src/test/java/io/github/resilience4j/retry/internal/ConsumerRetryTest.java" "resilience4j-retry/src/test/java/io/github/resilience4j/retry/internal/ConsumerRetryTest.java"

# Run the specific test classes
./gradlew :resilience4j-all:test \
          --tests io.github.resilience4j.decorators.DecoratorsTest \
          --no-daemon

all_status=$?

./gradlew :resilience4j-retry:test \
          --tests io.github.resilience4j.retry.internal.ConsumerRetryTest \
          --no-daemon

retry_status=$?

# Return success only if both tests pass
if [ $all_status -eq 0 ] && [ $retry_status -eq 0 ]; then
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
