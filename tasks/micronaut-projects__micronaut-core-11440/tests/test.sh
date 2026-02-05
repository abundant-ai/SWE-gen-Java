#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/java/io/micronaut/http/client"
cp "/tests/http-client/src/test/java/io/micronaut/http/client/ProxyBackpressureTest.java" "http-client/src/test/java/io/micronaut/http/client/ProxyBackpressureTest.java"
mkdir -p "http-client/src/test/resources"
cp "/tests/http-client/src/test/resources/junit-platform.properties" "http-client/src/test/resources/junit-platform.properties"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/java/io/micronaut/http/client/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-client/build/classes/java/test/io/micronaut/http/client/*.class

# Run specific tests using Gradle, skip Groovy compilation
./gradlew \
  :http-client:test --tests "io.micronaut.http.client.ProxyBackpressureTest" \
  -x compileTestGroovy \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
