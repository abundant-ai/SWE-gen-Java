#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "graal/src/test/groovy/io/micronaut/graal/reflect"
cp "/tests/graal/src/test/groovy/io/micronaut/graal/reflect/GraalTypeElementVisitorSpec.groovy" "graal/src/test/groovy/io/micronaut/graal/reflect/GraalTypeElementVisitorSpec.groovy"

# Run specific test using Gradle
./gradlew :micronaut-graal:test --tests "io.micronaut.graal.reflect.GraalTypeElementVisitorSpec" --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
