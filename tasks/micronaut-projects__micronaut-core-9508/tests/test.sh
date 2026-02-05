#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/context/env"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/context/env/DefaultEnvironmentSpec.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/context/env/DefaultEnvironmentSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch test-suite-groovy/src/test/groovy/io/micronaut/docs/context/env/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf test-suite-groovy/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :test-suite-groovy:test --tests "*DefaultEnvironmentSpec*" \
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
