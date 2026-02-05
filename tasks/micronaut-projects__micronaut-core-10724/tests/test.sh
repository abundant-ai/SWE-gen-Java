#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http/src/test/groovy/io/micronaut/http"
cp "/tests/http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy" "http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http/src/test/groovy/io/micronaut/http/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http/build/classes/

# Run the specific tests for this PR
./gradlew :http:cleanTest :http:test --tests "*MediaTypeSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
