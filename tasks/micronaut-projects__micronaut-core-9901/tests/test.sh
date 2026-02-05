#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "context/src/test/groovy/io/micronaut/scheduling"
cp "/tests/context/src/test/groovy/io/micronaut/scheduling/Intercepted.java" "context/src/test/groovy/io/micronaut/scheduling/Intercepted.java"
mkdir -p "context/src/test/groovy/io/micronaut/scheduling"
cp "/tests/context/src/test/groovy/io/micronaut/scheduling/MethodInterceptor.java" "context/src/test/groovy/io/micronaut/scheduling/MethodInterceptor.java"
mkdir -p "context/src/test/groovy/io/micronaut/scheduling"
cp "/tests/context/src/test/groovy/io/micronaut/scheduling/ScheduledInterceptedSpec.groovy" "context/src/test/groovy/io/micronaut/scheduling/ScheduledInterceptedSpec.groovy"
mkdir -p "context/src/test/groovy/io/micronaut/scheduling"
cp "/tests/context/src/test/groovy/io/micronaut/scheduling/ScheduledInterceptedSpecTask.java" "context/src/test/groovy/io/micronaut/scheduling/ScheduledInterceptedSpecTask.java"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/executable"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/executable/ExecutableBeanSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/executable/ExecutableBeanSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/executable"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/executable/StartupExecutable.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/executable/StartupExecutable.groovy"

# Update timestamps to force Gradle to detect changes
touch context/src/test/groovy/io/micronaut/scheduling/*.groovy 2>/dev/null || true
touch context/src/test/groovy/io/micronaut/scheduling/*.java 2>/dev/null || true
touch inject-groovy/src/test/groovy/io/micronaut/inject/executable/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf context/build/classes/ 2>/dev/null || true
rm -rf inject-groovy/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :context:test --tests "*ScheduledInterceptedSpec*" \
    :inject-groovy:test --tests "*ExecutableBeanSpec*" \
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
