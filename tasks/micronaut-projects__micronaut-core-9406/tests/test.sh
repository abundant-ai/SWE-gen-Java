#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/body"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/body/NettyJsonHandlerSpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/body/NettyJsonHandlerSpec.groovy"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeAutomaticTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeAutomaticTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeTest.java"
mkdir -p "http/src/test/groovy/io/micronaut/http"
cp "/tests/http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy" "http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy"
mkdir -p "json-core/src/test/groovy/io/micronaut/json/body"
cp "/tests/json-core/src/test/groovy/io/micronaut/json/body/JsonMessageHandlerSpec.groovy" "json-core/src/test/groovy/io/micronaut/json/body/JsonMessageHandlerSpec.groovy"
mkdir -p "json-core/src/test/groovy/io/micronaut/json/codec"
cp "/tests/json-core/src/test/groovy/io/micronaut/json/codec/JsonMediaTypeCodecSpec.groovy" "json-core/src/test/groovy/io/micronaut/json/codec/JsonMediaTypeCodecSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-netty/src/test/groovy/io/micronaut/http/netty/body/*.groovy 2>/dev/null || true
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/*.java 2>/dev/null || true
touch http/src/test/groovy/io/micronaut/http/*.groovy 2>/dev/null || true
touch json-core/src/test/groovy/io/micronaut/json/body/*.groovy 2>/dev/null || true
touch json-core/src/test/groovy/io/micronaut/json/codec/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-netty/build/classes/ 2>/dev/null || true
rm -rf http-server-tck/build/classes/ 2>/dev/null || true
rm -rf http/build/classes/ 2>/dev/null || true
rm -rf json-core/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :http-netty:test --tests "*NettyJsonHandlerSpec*" \
    :http-server-tck:test --tests "*JsonCodecAdditionalTypeAutomaticTest*" \
    :http-server-tck:test --tests "*JsonCodecAdditionalTypeTest*" \
    :http:test --tests "*MediaTypeSpec*" \
    :json-core:test --tests "*JsonMessageHandlerSpec*" \
    :json-core:test --tests "*JsonMediaTypeCodecSpec*" \
    --no-daemon --console=plain 2>&1)
gradle_exit=$?
set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    test_status=$gradle_exit
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
