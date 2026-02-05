#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/cookies"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/cookies/CookeFactorySpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/cookies/CookeFactorySpec.groovy"
mkdir -p "http-netty/src/test/groovy/io/micronaut/http/netty/cookies"
cp "/tests/http-netty/src/test/groovy/io/micronaut/http/netty/cookies/NettyServerCookieEncoderSpec.groovy" "http-netty/src/test/groovy/io/micronaut/http/netty/cookies/NettyServerCookieEncoderSpec.groovy"
mkdir -p "http/src/test/groovy/io/micronaut/http/cookie"
cp "/tests/http/src/test/groovy/io/micronaut/http/cookie/DefaultServerCookieEncoderSpec.groovy" "http/src/test/groovy/io/micronaut/http/cookie/DefaultServerCookieEncoderSpec.groovy"
mkdir -p "http/src/test/java/io/micronaut/http/cookie"
cp "/tests/http/src/test/java/io/micronaut/http/cookie/CookieHttpCookieAdapterTest.java" "http/src/test/java/io/micronaut/http/cookie/CookieHttpCookieAdapterTest.java"

# Update timestamps to force Gradle to detect changes
touch http-netty/src/test/groovy/io/micronaut/http/netty/cookies/*.groovy 2>/dev/null || true
touch http/src/test/groovy/io/micronaut/http/cookie/*.groovy 2>/dev/null || true
touch http/src/test/java/io/micronaut/http/cookie/*.java 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-netty/build/classes/
rm -rf http/build/classes/

# Run the specific tests for this PR
./gradlew :http-netty:cleanTest :http-netty:test --tests "*CookeFactorySpec" --tests "*NettyServerCookieEncoderSpec" \
          :http:cleanTest :http:test --tests "*DefaultServerCookieEncoderSpec" --tests "*CookieHttpCookieAdapterTest" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
