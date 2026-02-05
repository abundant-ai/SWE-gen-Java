#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject/src/test/groovy/io/micronaut/context/env"
cp "/tests/inject/src/test/groovy/io/micronaut/context/env/DefaultEnvironmentSpec.groovy" "inject/src/test/groovy/io/micronaut/context/env/DefaultEnvironmentSpec.groovy"

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject/build/classes/groovy/test/io/micronaut/context/env/*.class
rm -rf inject/build/classes/java/test/io/micronaut/context/env/*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject:test --tests "io.micronaut.context.env.DefaultEnvironmentSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
