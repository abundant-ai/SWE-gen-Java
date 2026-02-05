#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/body"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/body/AvailableNettyByteBodySpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/body/AvailableNettyByteBodySpec.groovy"
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/body"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/body/StreamingNettyByteBodySpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/body/StreamingNettyByteBodySpec.groovy"
mkdir -p "http/src/test/groovy/io/micronaut/http/body/stream"
cp "/tests/http/src/test/groovy/io/micronaut/http/body/stream/AvailableByteArrayBodySpec.groovy" "http/src/test/groovy/io/micronaut/http/body/stream/AvailableByteArrayBodySpec.groovy"
mkdir -p "http/src/test/groovy/io/micronaut/http/body/stream"
cp "/tests/http/src/test/groovy/io/micronaut/http/body/stream/InputStreamByteBodySpec.groovy" "http/src/test/groovy/io/micronaut/http/body/stream/InputStreamByteBodySpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-netty/src/test/groovy/io/micronaut/http/netty/body/*.groovy
touch http/src/test/groovy/io/micronaut/http/body/stream/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-netty/build/classes/groovy/test/io/micronaut/http/netty/body/*.class
rm -rf http/build/classes/groovy/test/io/micronaut/http/body/stream/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf http-netty/build/test-results/test/TEST-io.micronaut.http.netty.body.AvailableNettyByteBodySpec.xml
rm -rf http-netty/build/test-results/test/TEST-io.micronaut.http.netty.body.StreamingNettyByteBodySpec.xml
rm -rf http/build/test-results/test/TEST-io.micronaut.http.body.stream.AvailableByteArrayBodySpec.xml
rm -rf http/build/test-results/test/TEST-io.micronaut.http.body.stream.InputStreamByteBodySpec.xml

# Run specific tests using Gradle
./gradlew \
  :http-netty:cleanTest :http-netty:test \
  --tests "io.micronaut.http.netty.body.AvailableNettyByteBodySpec" \
  --tests "io.micronaut.http.netty.body.StreamingNettyByteBodySpec" \
  :http:cleanTest :http:test \
  --tests "io.micronaut.http.body.stream.AvailableByteArrayBodySpec" \
  --tests "io.micronaut.http.body.stream.InputStreamByteBodySpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
