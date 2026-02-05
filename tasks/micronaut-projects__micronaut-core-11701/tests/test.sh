#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/CacheControlTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/CacheControlTest.java"
mkdir -p "http/src/test/java/io/micronaut/http/cachecontrol"
cp "/tests/http/src/test/java/io/micronaut/http/cachecontrol/CacheControlTest.java" "http/src/test/java/io/micronaut/http/cachecontrol/CacheControlTest.java"
mkdir -p "http/src/test/java/io/micronaut/http/cachecontrol"
cp "/tests/http/src/test/java/io/micronaut/http/cachecontrol/ScopeTest.java" "http/src/test/java/io/micronaut/http/cachecontrol/ScopeTest.java"

# Update timestamps to force Gradle to detect changes
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/*.java 2>/dev/null || true
touch http/src/test/java/io/micronaut/http/cachecontrol/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-server-tck/build/classes/ 2>/dev/null || true
rm -rf http/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run http module tests (CacheControlTest and ScopeTest)
cd http
test_output+=$(../gradlew test --tests "*cachecontrol.CacheControlTest" --tests "*cachecontrol.ScopeTest" --no-daemon --console=plain 2>&1)
gradle_exit_1=$?
cd ..

# Run test-suite module that executes the http-server-tck CacheControlTest
cd test-suite-http-server-tck-netty
test_output+=$(../gradlew test --tests "*filter.CacheControlTest" --no-daemon --console=plain 2>&1)
gradle_exit_2=$?
cd ..

set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    # If either gradle command failed, mark as failure
    if [ $gradle_exit_1 -ne 0 ] || [ $gradle_exit_2 -ne 0 ]; then
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
