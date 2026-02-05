#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-logback-external-configuration/src/test/groovy/io/micronaut/logback"
cp "/tests/test-suite-logback-external-configuration/src/test/groovy/io/micronaut/logback/ExternalConfigurationSpec.groovy" "test-suite-logback-external-configuration/src/test/groovy/io/micronaut/logback/ExternalConfigurationSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch test-suite-logback-external-configuration/src/test/groovy/io/micronaut/logback/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf test-suite-logback-external-configuration/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run test-suite-logback-external-configuration module tests (ExternalConfigurationSpec)
cd test-suite-logback-external-configuration
test_output+=$(../gradlew test --tests "*logback.ExternalConfigurationSpec" --no-daemon --console=plain 2>&1)
gradle_exit=$?
cd ..

set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    # If gradle command failed, mark as failure
    if [ $gradle_exit -ne 0 ]; then
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
