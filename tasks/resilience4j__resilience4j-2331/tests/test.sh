#!/bin/bash

cd /app/src

# If powermock is referenced in build.gradle but not defined in libraries.gradle (happens when
# fix.patch removes powermock from libraries.gradle but not from build.gradle), remove the stale
# references so Gradle can evaluate the build without null dependency errors.
if grep -q "libraries.powermock" build.gradle && ! grep -q "powermock:" libraries.gradle; then
    sed -i '/testImplementation.*libraries\.powermock/d' build.gradle
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead"
cp "/tests/resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead/BulkheadFutureTest.java" "resilience4j-bulkhead/src/test/java/io/github/resilience4j/bulkhead/BulkheadFutureTest.java"
mkdir -p "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker"
cp "/tests/resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerTest.java" "resilience4j-circuitbreaker/src/test/java/io/github/resilience4j/circuitbreaker/CircuitBreakerTest.java"
mkdir -p "resilience4j-feign/src/test/java/io/github/resilience4j/feign"
cp "/tests/resilience4j-feign/src/test/java/io/github/resilience4j/feign/DecoratorInvocationHandlerTest.java" "resilience4j-feign/src/test/java/io/github/resilience4j/feign/DecoratorInvocationHandlerTest.java"
mkdir -p "resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter"
cp "/tests/resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter/RateLimiterWithConditionalDrainTest.java" "resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter/RateLimiterWithConditionalDrainTest.java"
mkdir -p "resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter/internal"
cp "/tests/resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter/internal/AtomicRateLimiterTest.java" "resilience4j-ratelimiter/src/test/java/io/github/resilience4j/ratelimiter/internal/AtomicRateLimiterTest.java"
mkdir -p "resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter/internal"
cp "/tests/resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter/internal/TimeLimiterImplTest.java" "resilience4j-timelimiter/src/test/java/io/github/resilience4j/timelimiter/internal/TimeLimiterImplTest.java"

# Run the specific test classes per module
./gradlew :resilience4j-bulkhead:test \
          --tests io.github.resilience4j.bulkhead.BulkheadFutureTest \
          --no-daemon
bulkhead_status=$?

./gradlew :resilience4j-circuitbreaker:test \
          --tests io.github.resilience4j.circuitbreaker.CircuitBreakerTest \
          --no-daemon
circuitbreaker_status=$?

./gradlew :resilience4j-feign:test \
          --tests io.github.resilience4j.feign.DecoratorInvocationHandlerTest \
          --no-daemon
feign_status=$?

./gradlew :resilience4j-ratelimiter:test \
          --tests io.github.resilience4j.ratelimiter.RateLimiterWithConditionalDrainTest \
          --tests io.github.resilience4j.ratelimiter.internal.AtomicRateLimiterTest \
          --no-daemon
ratelimiter_status=$?

./gradlew :resilience4j-timelimiter:test \
          --tests io.github.resilience4j.timelimiter.internal.TimeLimiterImplTest \
          --no-daemon
timelimiter_status=$?

# Return success only if all tests pass
if [ $bulkhead_status -eq 0 ] && [ $circuitbreaker_status -eq 0 ] && [ $feign_status -eq 0 ] && [ $ratelimiter_status -eq 0 ] && [ $timelimiter_status -eq 0 ]; then
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
