#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/FormLimitSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/FormLimitSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/*.class

# Run the specific test
./gradlew :http-server-netty:cleanTest :http-server-netty:test --tests "*FormLimitSpec" --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
