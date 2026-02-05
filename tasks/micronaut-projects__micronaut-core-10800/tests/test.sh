#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/beans"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/beans/RuntimeBeanDefinitionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/beans/RuntimeBeanDefinitionSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/beans/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/

# Run the specific test for this PR
./gradlew :inject-java:cleanTest :inject-java:test --tests "*RuntimeBeanDefinitionSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
