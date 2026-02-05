#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/RequestDecompressionConfigSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/RequestDecompressionConfigSpec.groovy"

# Remove compiled test class to force recompilation with the new test file
rm -rf build/classes/groovy/test/io/micronaut/http/server/netty/RequestDecompressionConfigSpec.class
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/RequestDecompressionConfigSpec*.class

# Run specific test using Gradle
./gradlew :micronaut-http-server-netty:test --tests "io.micronaut.http.server.netty.RequestDecompressionConfigSpec" --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
