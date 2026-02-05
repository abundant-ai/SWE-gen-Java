#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/HttpRequestTest.java" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/HttpRequestTest.java"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/NettyHttpRequestSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/NettyHttpRequestSpec.groovy"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/handler"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/handler/PipeliningServerHandlerSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/handler/PipeliningServerHandlerSpec.groovy"
mkdir -p "http-server-netty/src/test/java/io/micronaut/http/server/netty/jackson"
cp "/tests/http-server-netty/src/test/java/io/micronaut/http/server/netty/jackson/JsonContentProcessorBenchmark.java" "http-server-netty/src/test/java/io/micronaut/http/server/netty/jackson/JsonContentProcessorBenchmark.java"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/*.java 2>/dev/null || true
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/*.groovy 2>/dev/null || true
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/handler/*.groovy 2>/dev/null || true
touch http-server-netty/src/test/java/io/micronaut/http/server/netty/jackson/*.java 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :http-server-netty:cleanTest :http-server-netty:test --tests "*HttpRequestTest*" --tests "*NettyHttpRequestSpec*" --tests "*PipeliningServerHandlerSpec*" --tests "*JsonContentProcessorBenchmark*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
