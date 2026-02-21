#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerTest.java"
mkdir -p "resilience4j-spring/src/test/java/io/github/resilience4j/circuitbreaker/configure"
cp "/tests/resilience4j-spring/src/test/java/io/github/resilience4j/circuitbreaker/configure/IgnoreClassBindingExceptionConverterTest.java" "resilience4j-spring/src/test/java/io/github/resilience4j/circuitbreaker/configure/IgnoreClassBindingExceptionConverterTest.java"

# Run the specific test classes across the circuitbreaker and spring modules
./gradlew :resilience4j-circuitbreaker:test \
          --tests io.github.resilience4j.circuitbreaker.CircuitBreakerTest \
          --no-daemon && \
./gradlew :resilience4j-spring:test \
          --tests io.github.resilience4j.circuitbreaker.configure.IgnoreClassBindingExceptionConverterTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
