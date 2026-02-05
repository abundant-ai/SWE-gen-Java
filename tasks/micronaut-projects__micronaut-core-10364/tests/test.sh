#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
# In HEAD, the test is in http-cookie-netty module
# In BASE, http-cookie-netty module doesn't exist, so the test should fail
mkdir -p "http-cookie-netty/src/test/groovy/io/micronaut/http/netty/cookies"
cp "/tests/http-cookie-netty/src/test/groovy/io/micronaut/http/netty/cookies/NettyCookiesSpec.groovy" "http-cookie-netty/src/test/groovy/io/micronaut/http/netty/cookies/NettyCookiesSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-cookie-netty/src/test/groovy/io/micronaut/http/netty/cookies/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-cookie-netty/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
# In BASE: this will fail because http-cookie-netty module doesn't exist
# In HEAD: this will succeed because http-cookie-netty module exists
./gradlew \
    :http-cookie-netty:cleanTest :http-cookie-netty:test --tests "*NettyCookiesSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
