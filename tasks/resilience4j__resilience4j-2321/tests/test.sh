#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/SpringBootCommonTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/SpringBootCommonTest.java"
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/bulkhead/autoconfigure"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/bulkhead/autoconfigure/BulkheadAutoConfigurationCustomizerTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/bulkhead/autoconfigure/BulkheadAutoConfigurationCustomizerTest.java"
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/circuitbreaker/autoconfigure"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/circuitbreaker/autoconfigure/CircuitBreakerAutoConfigurationCustomizerTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/circuitbreaker/autoconfigure/CircuitBreakerAutoConfigurationCustomizerTest.java"
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/ratelimiter/autoconfigure"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/ratelimiter/autoconfigure/RateLimiterAutoConfigurationCustomizerTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/ratelimiter/autoconfigure/RateLimiterAutoConfigurationCustomizerTest.java"
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/retry/autoconfigure"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/retry/autoconfigure/RetryAutoConfigurationCustomizerTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/retry/autoconfigure/RetryAutoConfigurationCustomizerTest.java"
mkdir -p "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/timelimiter/autoconfigure"
cp "/tests/resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/timelimiter/autoconfigure/TimeLimiterAutoConfigurationCustomizerTest.java" "resilience4j-spring-boot3/src/test/java/io/github/resilience4j/springboot3/timelimiter/autoconfigure/TimeLimiterAutoConfigurationCustomizerTest.java"

# Run the specific test classes in the resilience4j-spring-boot3 module
./gradlew :resilience4j-spring-boot3:test \
          --tests io.github.resilience4j.springboot3.SpringBootCommonTest \
          --tests io.github.resilience4j.springboot3.bulkhead.autoconfigure.BulkheadAutoConfigurationCustomizerTest \
          --tests io.github.resilience4j.springboot3.circuitbreaker.autoconfigure.CircuitBreakerAutoConfigurationCustomizerTest \
          --tests io.github.resilience4j.springboot3.ratelimiter.autoconfigure.RateLimiterAutoConfigurationCustomizerTest \
          --tests io.github.resilience4j.springboot3.retry.autoconfigure.RetryAutoConfigurationCustomizerTest \
          --tests io.github.resilience4j.springboot3.timelimiter.autoconfigure.TimeLimiterAutoConfigurationCustomizerTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
