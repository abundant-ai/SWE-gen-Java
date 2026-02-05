#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/body"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/body/DefaultHandlerSpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/body/DefaultHandlerSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-netty/src/test/groovy/io/micronaut/http/netty/body/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-netty/build/classes/groovy/test/io/micronaut/http/netty/body/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf http-netty/build/test-results/test/TEST-io.micronaut.http.netty.body.DefaultHandlerSpec.xml

# Run specific tests using Gradle
./gradlew \
  :http-netty:cleanTest :http-netty:test \
  --tests "io.micronaut.http.netty.body.DefaultHandlerSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
