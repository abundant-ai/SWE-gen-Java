#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client/netty"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/netty/ConnectionManagerSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/netty/ConnectionManagerSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/groovy/io/micronaut/http/client/netty/*.groovy 2>/dev/null || true
touch http-client/src/test/groovy/io/micronaut/http/client/netty/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-client/build/classes/ 2>/dev/null || true

# Run the specific test for this PR
set +e  # Don't exit on error, we'll check manually

cd http-client
test_output=$(../gradlew test --tests "io.micronaut.http.client.netty.ConnectionManagerSpec" \
  --no-daemon --console=plain 2>&1)
test_status=$?
cd ..

echo "$test_output"

set -e

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
