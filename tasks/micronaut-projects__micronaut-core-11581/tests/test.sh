#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "runtime/src/test/groovy/io/micronaut/runtime/converters/time"
cp "/tests/runtime/src/test/groovy/io/micronaut/runtime/converters/time/TimeConverterRegistrarSpec.groovy" "runtime/src/test/groovy/io/micronaut/runtime/converters/time/TimeConverterRegistrarSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch runtime/src/test/groovy/io/micronaut/runtime/converters/time/TimeConverterRegistrarSpec.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf runtime/build/classes/groovy/test/io/micronaut/runtime/converters/time/*.class
rm -rf runtime/build/classes/java/test/io/micronaut/runtime/converters/time/*.class

# Run specific tests using Gradle
./gradlew \
  :runtime:test --tests "io.micronaut.runtime.converters.time.TimeConverterRegistrarSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
