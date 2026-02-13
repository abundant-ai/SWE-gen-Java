#!/bin/bash

cd /app/src

# No additional environment variables needed for Gradle tests

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerConfigTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerConfigTest.java"
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/internal/CircuitBreakerStateMachineTest.java"
mkdir -p "resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure"
cp "/tests/resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure/CommonsConfigurationCircuitBreakerConfigurationTest.java" "resilience4j-commons-configuration/src/test/java/io/github/resilience4j/commons/configuration/circuitbreaker/configure/CommonsConfigurationCircuitBreakerConfigurationTest.java"
mkdir -p "resilience4j-commons-configuration/src/test/resources"
cp "/tests/resilience4j-commons-configuration/src/test/resources/resilience.properties" "resilience4j-commons-configuration/src/test/resources/resilience.properties"
mkdir -p "resilience4j-commons-configuration/src/test/resources"
cp "/tests/resilience4j-commons-configuration/src/test/resources/resilience.yaml" "resilience4j-commons-configuration/src/test/resources/resilience.yaml"
mkdir -p "resilience4j-framework-common/src/test/java/io/github/resilience4j/common/circuitbreaker/configuration"
cp "/tests/resilience4j-framework-common/src/test/java/io/github/resilience4j/common/circuitbreaker/configuration/CommonCircuitBreakerConfigurationPropertiesTest.java" "resilience4j-framework-common/src/test/java/io/github/resilience4j/common/circuitbreaker/configuration/CommonCircuitBreakerConfigurationPropertiesTest.java"

# Run the specific test classes in their respective modules
./gradlew :resilience4j-circuitbreaker:test \
          --tests io.github.resilience4j.circuitbreaker.CircuitBreakerConfigTest \
          --tests io.github.resilience4j.circuitbreaker.internal.CircuitBreakerStateMachineTest \
          :resilience4j-commons-configuration:test \
          --tests io.github.resilience4j.commons.configuration.circuitbreaker.configure.CommonsConfigurationCircuitBreakerConfigurationTest \
          :resilience4j-framework-common:test \
          --tests io.github.resilience4j.common.circuitbreaker.configuration.CommonCircuitBreakerConfigurationPropertiesTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
