#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configuration"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaDefaultsSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaDefaultsSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configuration"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configuration"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaValidationSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationJsonSchemaValidationSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/configuration/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/configuration/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

cd inject-java
test_output=$(../gradlew test --tests "io.micronaut.inject.configuration.ConfigurationJsonSchemaDefaultsSpec" \
  --tests "io.micronaut.inject.configuration.ConfigurationJsonSchemaSpec" \
  --tests "io.micronaut.inject.configuration.ConfigurationJsonSchemaValidationSpec" \
  --no-daemon --console=plain 2>&1)
test_status=$?
cd ..

echo "$test_output"

set -e

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
