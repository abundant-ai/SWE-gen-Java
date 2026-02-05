#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/ClassElementSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/ClassElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-kotlin/build/classes/groovy/test/io/micronaut/kotlin/processing/inject/ast/*.class

# Run the specific test
./gradlew \
  :inject-kotlin:cleanTest :inject-kotlin:test \
  --tests "*ClassElementSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
