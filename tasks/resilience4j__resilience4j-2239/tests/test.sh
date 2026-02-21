#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerMetricsTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerMetricsTest.java"
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java"

# Run the specific test classes in the circuitbreaker module
./gradlew :resilience4j-circuitbreaker:test \
          --tests io.github.resilience4j.circuitbreaker.internal.CircuitBreakerMetricsTest \
          --tests io.github.resilience4j.circuitbreaker.internal.CircuitBreakerStateMachineTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
