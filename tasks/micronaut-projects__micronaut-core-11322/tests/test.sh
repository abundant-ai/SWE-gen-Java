#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http/src/test/groovy/io/micronaut/http/util"
cp "/tests/http/src/test/groovy/io/micronaut/http/util/HttpUtilSpec.groovy" "http/src/test/groovy/io/micronaut/http/util/HttpUtilSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http/src/test/groovy/io/micronaut/http/util/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http/build/classes/ 2>/dev/null || true

# Run the specific test for this PR
set +e  # Don't exit on error, we'll check manually

cd http
test_output=$(../gradlew test --tests "io.micronaut.http.util.HttpUtilSpec" \
  --no-daemon --console=plain 2>&1)
test_status=$?
cd ..

set -e

echo "$test_output"

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
