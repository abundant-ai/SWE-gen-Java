#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "context/src/test/groovy/io/micronaut/runtime/converters/time"
cp "/tests/context/src/test/groovy/io/micronaut/runtime/converters/time/TimeConverterConfigurationSpec.groovy" "context/src/test/groovy/io/micronaut/runtime/converters/time/TimeConverterConfigurationSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch context/src/test/groovy/io/micronaut/runtime/converters/time/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf context/build/classes/groovy/test/io/micronaut/runtime/converters/time/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf context/build/test-results/test/TEST-io.micronaut.runtime.converters.time.TimeConverterConfigurationSpec.xml

# Run specific tests using Gradle
./gradlew \
  :micronaut-context:cleanTest :micronaut-context:test \
  --tests "io.micronaut.runtime.converters.time.TimeConverterConfigurationSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
