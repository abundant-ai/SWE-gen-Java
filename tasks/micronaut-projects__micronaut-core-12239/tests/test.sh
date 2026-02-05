#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jackson-databind/src/test/groovy/io/micronaut/jackson/serialize"
cp "/tests/jackson-databind/src/test/groovy/io/micronaut/jackson/serialize/JacksonObjectSerializerSpec.groovy" "jackson-databind/src/test/groovy/io/micronaut/jackson/serialize/JacksonObjectSerializerSpec.groovy"
mkdir -p "jackson-databind/src/test/groovy/io/micronaut/json"
cp "/tests/jackson-databind/src/test/groovy/io/micronaut/json/JsonObjectSerializerSpec.groovy" "jackson-databind/src/test/groovy/io/micronaut/json/JsonObjectSerializerSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch jackson-databind/src/test/groovy/io/micronaut/jackson/serialize/*.groovy 2>/dev/null || true
touch jackson-databind/src/test/groovy/io/micronaut/json/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf jackson-databind/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(cd jackson-databind && ../gradlew test --tests "*JacksonObjectSerializerSpec*" --tests "*JsonObjectSerializerSpec*" \
    --no-daemon --console=plain 2>&1)
gradle_exit=$?
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
