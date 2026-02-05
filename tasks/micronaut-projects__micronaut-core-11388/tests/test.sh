#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/java/io/micronaut/core/util"
cp "/tests/core/src/test/java/io/micronaut/core/util/NativeImageUtilsInNativeImageTest.java" "core/src/test/java/io/micronaut/core/util/NativeImageUtilsInNativeImageTest.java"
mkdir -p "core/src/test/java/io/micronaut/core/util"
cp "/tests/core/src/test/java/io/micronaut/core/util/NativeImageUtilsTest.java" "core/src/test/java/io/micronaut/core/util/NativeImageUtilsTest.java"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/aggregator"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/aggregator/HealthAggregatorSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/aggregator/HealthAggregatorSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/indicator/threads"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorConfigurationSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorConfigurationSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/indicator/threads"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/monitor"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/monitor/HealthMonitorTaskSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/monitor/HealthMonitorTaskSpec.groovy"
mkdir -p "management/src/test/java/io/micronaut/management/health/indicator/threads"
cp "/tests/management/src/test/java/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorTest.java" "management/src/test/java/io/micronaut/management/health/indicator/threads/DeadlockedThreadsHealthIndicatorTest.java"

# Update timestamps to force Gradle to detect changes
touch core/src/test/java/io/micronaut/core/util/*.java 2>/dev/null || true
touch management/src/test/groovy/io/micronaut/management/health/aggregator/*.groovy 2>/dev/null || true
touch management/src/test/groovy/io/micronaut/management/health/indicator/threads/*.groovy 2>/dev/null || true
touch management/src/test/groovy/io/micronaut/management/health/monitor/*.groovy 2>/dev/null || true
touch management/src/test/java/io/micronaut/management/health/indicator/threads/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf core/build/classes/ 2>/dev/null || true
rm -rf management/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run core module tests
cd core
test_output+=$(../gradlew test --tests "io.micronaut.core.util.NativeImageUtilsInNativeImageTest" \
  --tests "io.micronaut.core.util.NativeImageUtilsTest" \
  --no-daemon --console=plain 2>&1)
gradle_exit_1=$?
cd ..

# Run management module tests
cd management
test_output+=$(../gradlew test --tests "io.micronaut.management.health.aggregator.HealthAggregatorSpec" \
  --tests "io.micronaut.management.health.indicator.threads.DeadlockedThreadsHealthIndicatorConfigurationSpec" \
  --tests "io.micronaut.management.health.indicator.threads.DeadlockedThreadsHealthIndicatorSpec" \
  --tests "io.micronaut.management.health.monitor.HealthMonitorTaskSpec" \
  --tests "io.micronaut.management.health.indicator.threads.DeadlockedThreadsHealthIndicatorTest" \
  --no-daemon --console=plain 2>&1)
gradle_exit_2=$?
cd ..

set -e

echo "$test_output"

# Check if both gradle commands succeeded (both must pass)
if [ $gradle_exit_1 -eq 0 ] && [ $gradle_exit_2 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
