#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "context-propagation/src/test/groovy/io/micronaut/context/propagation/instrument/execution"
cp "/tests/context-propagation/src/test/groovy/io/micronaut/context/propagation/instrument/execution/ExecutorServiceInstrumenterSpec.groovy" "context-propagation/src/test/groovy/io/micronaut/context/propagation/instrument/execution/ExecutorServiceInstrumenterSpec.groovy"

# Remove compiled test classes to force recompilation with the new test files
rm -rf context-propagation/build/classes/groovy/test/io/micronaut/context/propagation/instrument/execution/ExecutorServiceInstrumenterSpec*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-context-propagation:test --tests "io.micronaut.context.propagation.instrument.execution.ExecutorServiceInstrumenterSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
