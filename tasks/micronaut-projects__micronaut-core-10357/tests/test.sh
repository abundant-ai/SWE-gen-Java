#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/ClientSpecificLoggerSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/ClientSpecificLoggerSpec.groovy"
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client/config"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/config/DefaultHttpClientConfigurationSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/config/DefaultHttpClientConfigurationSpec.groovy"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/websocket"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/websocket/BinaryWebSocketSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/websocket/BinaryWebSocketSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/indicator/client"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/indicator/client/ServiceHttpClientHealthIndicatorSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/indicator/client/ServiceHttpClientHealthIndicatorSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/groovy/io/micronaut/http/client/*.groovy 2>/dev/null || true
touch http-client/src/test/groovy/io/micronaut/http/client/config/*.groovy 2>/dev/null || true
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/websocket/*.groovy 2>/dev/null || true
touch management/src/test/groovy/io/micronaut/management/health/indicator/client/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-client/build/classes/ 2>/dev/null || true
rm -rf http-server-netty/build/classes/ 2>/dev/null || true
rm -rf management/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :http-client:cleanTest :http-client:test --tests "*ClientSpecificLoggerSpec*" --tests "*DefaultHttpClientConfigurationSpec*" \
    :http-server-netty:cleanTest :http-server-netty:test --tests "*BinaryWebSocketSpec*" \
    :management:cleanTest :management:test --tests "*ServiceHttpClientHealthIndicatorSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
