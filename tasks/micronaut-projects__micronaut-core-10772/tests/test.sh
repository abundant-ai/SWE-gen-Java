#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/websocket"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/websocket/WebsocketExecuteOnSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/websocket/WebsocketExecuteOnSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/websocket/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/

# Run the specific tests for this PR
./gradlew :http-server-netty:cleanTest :http-server-netty:test --tests "*WebsocketExecuteOnSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
