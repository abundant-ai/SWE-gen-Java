#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "management/src/test/groovy/io/micronaut/management/health/aggregator"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/aggregator/HealthAggregatorSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/aggregator/HealthAggregatorSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/monitor"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/monitor/HealthMonitorTaskSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/monitor/HealthMonitorTaskSpec.groovy"
mkdir -p "management/src/test/resources"
cp "/tests/management/src/test/resources/logback-test.xml" "management/src/test/resources/logback-test.xml"

# Update timestamps to force Gradle to detect changes
touch management/src/test/groovy/io/micronaut/management/health/aggregator/*.groovy 2>/dev/null || true
touch management/src/test/groovy/io/micronaut/management/health/monitor/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf management/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :management:test --tests "*HealthAggregatorSpec*" \
    :management:test --tests "*HealthMonitorTaskSpec*" \
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
