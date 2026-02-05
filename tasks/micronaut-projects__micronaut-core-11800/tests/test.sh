#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler"
cp "/tests/http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/Http1RequestEventTest.java" "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/Http1RequestEventTest.java"
mkdir -p "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler"
cp "/tests/http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/Http2RequestEventTest.java" "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/Http2RequestEventTest.java"
mkdir -p "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler"
cp "/tests/http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/HttpRequestEventTest.java" "http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/HttpRequestEventTest.java"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/java/io/micronaut/http/server/netty/handler/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# http-server-netty tests (Http1RequestEventTest, Http2RequestEventTest, HttpRequestEventTest)
cd http-server-netty
test_output+=$(../gradlew test --tests "*Http1RequestEventTest*" --tests "*Http2RequestEventTest*" --tests "*HttpRequestEventTest*" --no-daemon --console=plain 2>&1)
gradle_exit=$?
cd ..

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
