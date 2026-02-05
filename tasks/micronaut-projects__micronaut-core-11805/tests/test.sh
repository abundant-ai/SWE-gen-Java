#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retry/src/test/groovy/io/micronaut/retry/intercept"
cp "/tests/retry/src/test/groovy/io/micronaut/retry/intercept/CircuitBreakerRetrySpec.groovy" "retry/src/test/groovy/io/micronaut/retry/intercept/CircuitBreakerRetrySpec.groovy"
mkdir -p "retry/src/test/groovy/io/micronaut/retry/intercept"
cp "/tests/retry/src/test/groovy/io/micronaut/retry/intercept/SimpleRetryInstanceSpec.groovy" "retry/src/test/groovy/io/micronaut/retry/intercept/SimpleRetryInstanceSpec.groovy"

# Remove compiled test classes to force recompilation with the new test files
rm -rf retry/build/classes/groovy/test/io/micronaut/retry/intercept/*.class
rm -rf retry/build/classes/java/test/io/micronaut/retry/intercept/*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-retry:test --tests "io.micronaut.retry.intercept.CircuitBreakerRetrySpec" \
  --tests "io.micronaut.retry.intercept.SimpleRetryInstanceSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
