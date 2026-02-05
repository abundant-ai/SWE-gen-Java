#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/visitor"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/visitor/BeanIntrospectionSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/visitor/BeanIntrospectionSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/visitor/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-kotlin/build/classes/

# Run the specific tests for this PR
./gradlew :inject-kotlin:cleanTest :inject-kotlin:test --tests "*BeanIntrospectionSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
