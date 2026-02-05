#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/inject/annotation/InheritedNullableAnnotationSpec.groovy" "inject-java-test/src/test/groovy/io/micronaut/inject/annotation/InheritedNullableAnnotationSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java-test/src/test/groovy/io/micronaut/inject/annotation/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java-test/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :inject-java-test:test --tests "*InheritedNullableAnnotationSpec*" \
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
