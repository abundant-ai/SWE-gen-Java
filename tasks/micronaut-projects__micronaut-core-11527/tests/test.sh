#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configurations"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configurations/RequiresBeanSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configurations/RequiresBeanSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/configurations/RequiresBeanSpec.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/inject/configurations/*.class
rm -rf inject-java/build/classes/java/test/io/micronaut/inject/configurations/*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject-java:test --tests "io.micronaut.inject.configurations.RequiresBeanSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
