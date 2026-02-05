#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http/src/test/groovy/io/micronaut/http"
cp "/tests/http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy" "http/src/test/groovy/io/micronaut/http/MediaTypeSpec.groovy"
mkdir -p "test-suite/src/test/java/io/micronaut/docs/jsonpatch"
cp "/tests/test-suite/src/test/java/io/micronaut/docs/jsonpatch/JsonPatchTest.java" "test-suite/src/test/java/io/micronaut/docs/jsonpatch/JsonPatchTest.java"

# Update timestamps to force Gradle to detect changes
touch http/src/test/groovy/io/micronaut/http/*.groovy 2>/dev/null || true
touch test-suite/src/test/java/io/micronaut/docs/jsonpatch/*.java 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http/build/classes/ 2>/dev/null || true
rm -rf test-suite/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :http:cleanTest :http:test --tests "*MediaTypeSpec*" \
    :test-suite:cleanTest :test-suite:test --tests "*JsonPatchTest*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
