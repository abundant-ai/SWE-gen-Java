#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/ResponseBodySpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/ResponseBodySpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/groovy/io/micronaut/http/client/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-client/build/classes/groovy/test/io/micronaut/http/client/*.class

# Run the specific test
./gradlew :http-client:cleanTest :http-client:test --tests "*ResponseBodySpec" --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
