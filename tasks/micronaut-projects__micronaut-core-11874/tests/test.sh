#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject/src/test/groovy/io/micronaut/context"
cp "/tests/inject/src/test/groovy/io/micronaut/context/BeanEventListenerOrderingSpec.groovy" "inject/src/test/groovy/io/micronaut/context/BeanEventListenerOrderingSpec.groovy"
mkdir -p "test-suite/src/test/groovy/io/micronaut"
cp "/tests/test-suite/src/test/groovy/io/micronaut/EventListenerSpec.groovy" "test-suite/src/test/groovy/io/micronaut/EventListenerSpec.groovy"

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject/build/classes/groovy/test/io/micronaut/context/BeanEventListenerOrderingSpec*.class
rm -rf test-suite/build/classes/groovy/test/io/micronaut/EventListenerSpec*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject:test --tests "io.micronaut.context.BeanEventListenerOrderingSpec" \
  :test-suite:test --tests "io.micronaut.EventListenerSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
