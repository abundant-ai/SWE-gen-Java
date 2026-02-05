#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/body"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/body/BodyConversionSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/body/BodyConversionSpec.groovy"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/BodyTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/BodyTest.java"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/body/*.groovy 2>/dev/null || true
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/ 2>/dev/null || true
rm -rf http-server-tck/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

cd http-server-netty
test_output=$(../gradlew test --tests "io.micronaut.http.server.netty.body.BodyConversionSpec" \
  --no-daemon --console=plain 2>&1)
test_status=$?
cd ..

echo "$test_output"

# Only run the second test if the first one passed
if [ $test_status -eq 0 ]; then
  cd http-server-tck
  test_output=$(../gradlew test --tests "io.micronaut.http.server.tck.tests.BodyTest" \
    --no-daemon --console=plain 2>&1)
  test_status=$?
  cd ..

  echo "$test_output"
fi

set -e

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
