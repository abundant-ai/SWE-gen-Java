#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerRegistryTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerRegistryTest.java"
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java"
mkdir -p "resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure"
cp "/tests/resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure/CommonsConfigurationCircuitBreakerConfigurationTest.java" "resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure/CommonsConfigurationCircuitBreakerConfigurationTest.java"
mkdir -p "resilience4j-commons-configuration/src/test/resources"
cp "/tests/resilience4j-commons-configuration/src/test/resources/resilience.properties" "resilience4j-commons-configuration/src/test/resources/resilience.properties"
mkdir -p "resilience4j-commons-configuration/src/test/resources"
cp "/tests/resilience4j-commons-configuration/src/test/resources/resilience.yaml" "resilience4j-commons-configuration/src/test/resources/resilience.yaml"

# Run the specific test classes
./gradlew :resilience4j-circuitbreaker:test \
          --tests io.github.resilience4j.circuitbreaker.CircuitBreakerRegistryTest \
          --tests io.github.resilience4j.circuitbreaker.internal.CircuitBreakerStateMachineTest \
          --no-daemon

cb_status=$?

./gradlew :resilience4j-commons-configuration:test \
          --tests io.github.resilience4j.commons.configuration.circuitbreaker.configure.CommonsConfigurationCircuitBreakerConfigurationTest \
          --no-daemon

commons_status=$?

# Return success only if both tests pass
if [ $cb_status -eq 0 ] && [ $commons_status -eq 0 ]; then
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
