#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter"
cp "/tests/resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter/TimeLimiterRegistryTest.java" "resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter/TimeLimiterRegistryTest.java"

# Run the specific test class in the timelimiter module
./gradlew :resilience4j-timelimiter:test \
          --tests io.github.resilience4j.timelimiter.TimeLimiterRegistryTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
