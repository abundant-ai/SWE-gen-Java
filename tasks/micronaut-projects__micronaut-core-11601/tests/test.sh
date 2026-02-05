#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/errors"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/errors/MalformedUriDisabledValidationSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/errors/MalformedUriDisabledValidationSpec.groovy"
mkdir -p "router/src/test/java/io/micronaut/web/router/uri"
cp "/tests/router/src/test/java/io/micronaut/web/router/uri/PercentDecoder.java" "router/src/test/java/io/micronaut/web/router/uri/PercentDecoder.java"
mkdir -p "router/src/test/java/io/micronaut/web/router/uri"
cp "/tests/router/src/test/java/io/micronaut/web/router/uri/UriUtilTest.java" "router/src/test/java/io/micronaut/web/router/uri/UriUtilTest.java"
mkdir -p "router/src/test/java/io/micronaut/web/router/uri"
cp "/tests/router/src/test/java/io/micronaut/web/router/uri/WhatwgParser.java" "router/src/test/java/io/micronaut/web/router/uri/WhatwgParser.java"
mkdir -p "router/src/test/java/io/micronaut/web/router/uri"
cp "/tests/router/src/test/java/io/micronaut/web/router/uri/WhatwgUrl.java" "router/src/test/java/io/micronaut/web/router/uri/WhatwgUrl.java"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/errors/*.groovy 2>/dev/null || true
touch router/src/test/java/io/micronaut/web/router/uri/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/ 2>/dev/null || true
rm -rf router/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run http-server-netty module tests (MalformedUriDisabledValidationSpec)
cd http-server-netty
test_output+=$(../gradlew test --tests "*MalformedUriDisabledValidationSpec" --no-daemon --console=plain 2>&1)
gradle_exit_netty=$?
cd ..

# Run router module tests (UriUtilTest)
cd router
test_output+=$(../gradlew test --tests "*UriUtilTest" --no-daemon --console=plain 2>&1)
gradle_exit_router=$?
cd ..

set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    # If gradle command failed, mark as failure
    if [ $gradle_exit_netty -ne 0 ] || [ $gradle_exit_router -ne 0 ]; then
        test_status=1
    else
        test_status=0
    fi
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
