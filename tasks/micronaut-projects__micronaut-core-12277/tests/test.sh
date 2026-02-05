#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject/src/test/java/io/micronaut/context"
cp "/tests/inject/src/test/java/io/micronaut/context/BeanConfigurationsPredicateTest.java" "inject/src/test/java/io/micronaut/context/BeanConfigurationsPredicateTest.java"
mkdir -p "inject/src/test/java/test/disabled"
cp "/tests/inject/src/test/java/test/disabled/MyDisabledBean.java" "inject/src/test/java/test/disabled/MyDisabledBean.java"
mkdir -p "inject/src/test/java/test/enabled"
cp "/tests/inject/src/test/java/test/enabled/MyEnabledBean.java" "inject/src/test/java/test/enabled/MyEnabledBean.java"

# Update timestamps to force Gradle to detect changes
touch inject/src/test/java/io/micronaut/context/*.java 2>/dev/null || true
touch inject/src/test/java/test/disabled/*.java 2>/dev/null || true
touch inject/src/test/java/test/enabled/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf inject/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(cd inject && ../gradlew test --tests "*BeanConfigurationsPredicateTest*" \
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
