#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/java/io/micronaut/core/util"
cp "/tests/core/src/test/java/io/micronaut/core/util/StringUtilsTest.java" "core/src/test/java/io/micronaut/core/util/StringUtilsTest.java"
mkdir -p "http/src/test/java/io/micronaut/http/cookie"
cp "/tests/http/src/test/java/io/micronaut/http/cookie/CookieSizeExceededExceptionTest.java" "http/src/test/java/io/micronaut/http/cookie/CookieSizeExceededExceptionTest.java"
mkdir -p "http/src/test/java/io/micronaut/http/cookie"
cp "/tests/http/src/test/java/io/micronaut/http/cookie/CookieUtilsTest.java" "http/src/test/java/io/micronaut/http/cookie/CookieUtilsTest.java"
mkdir -p "test-suite/src/test/java/io/micronaut/http/server/exceptions"
cp "/tests/test-suite/src/test/java/io/micronaut/http/server/exceptions/CookieSizeExceededHandlerTest.java" "test-suite/src/test/java/io/micronaut/http/server/exceptions/CookieSizeExceededHandlerTest.java"

# Update timestamps to force Gradle to detect changes
touch core/src/test/java/io/micronaut/core/util/*.java 2>/dev/null || true
touch http/src/test/java/io/micronaut/http/cookie/*.java 2>/dev/null || true
touch test-suite/src/test/java/io/micronaut/http/server/exceptions/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf core/build/classes/ 2>/dev/null || true
rm -rf http/build/classes/ 2>/dev/null || true
rm -rf test-suite/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# core tests (StringUtilsTest)
cd core
test_output+=$(../gradlew test --tests "*StringUtilsTest*" --no-daemon --console=plain 2>&1)
gradle_exit=$?
cd ..

# http tests (CookieSizeExceededExceptionTest and CookieUtilsTest)
cd http
test_output+=$(../gradlew test --tests "*CookieSizeExceededExceptionTest*" --no-daemon --console=plain 2>&1)
test_output+=$(../gradlew test --tests "*CookieUtilsTest*" --no-daemon --console=plain 2>&1)
gradle_exit=$?
cd ..

# test-suite tests (CookieSizeExceededHandlerTest)
cd test-suite
test_output+=$(../gradlew test --tests "*CookieSizeExceededHandlerTest*" --no-daemon --console=plain 2>&1)
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
