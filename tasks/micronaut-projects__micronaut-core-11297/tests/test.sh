#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http/src/test/groovy/io/micronaut/http/reactive/execution"
cp "/tests/http/src/test/groovy/io/micronaut/http/reactive/execution/ReactorExecutionFlowImplSpec.groovy" "http/src/test/groovy/io/micronaut/http/reactive/execution/ReactorExecutionFlowImplSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http/src/test/groovy/io/micronaut/http/reactive/execution/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http/build/classes/groovy/test/io/micronaut/http/reactive/execution/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf http/build/test-results/test/TEST-io.micronaut.http.reactive.execution.ReactorExecutionFlowImplSpec.xml

# Run specific tests using Gradle
./gradlew \
  :http:cleanTest :http:test \
  --tests "io.micronaut.http.reactive.execution.ReactorExecutionFlowImplSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
