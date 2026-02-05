#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/java/io/micronaut/http/server/exceptions/response"
cp "/tests/http-server-netty/src/test/java/io/micronaut/http/server/exceptions/response/HtmlErrorResponseCacheTest.java" "http-server-netty/src/test/java/io/micronaut/http/server/exceptions/response/HtmlErrorResponseCacheTest.java"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/java/io/micronaut/http/server/exceptions/response/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/java/test/io/micronaut/http/server/exceptions/response/*.class

# Run specific tests using Gradle
./gradlew \
  :http-server-netty:test --tests "io.micronaut.http.server.exceptions.response.HtmlErrorResponseCacheTest" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
