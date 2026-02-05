#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configuration"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationBuilderSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configuration/ConfigurationBuilderSpec.groovy"
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/BeanDefinitionSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/BeanDefinitionSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/configuration/*.groovy
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/inject/configuration/*.class
rm -rf inject-kotlin/build/classes/kotlin/test/io/micronaut/kotlin/processing/beans/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf inject-java/build/test-results/test/TEST-io.micronaut.inject.configuration.ConfigurationBuilderSpec.xml
rm -rf inject-kotlin/build/test-results/test/TEST-io.micronaut.kotlin.processing.beans.BeanDefinitionSpec.xml

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject-java:cleanTest :micronaut-inject-java:test \
  --tests "io.micronaut.inject.configuration.ConfigurationBuilderSpec" \
  :micronaut-inject-kotlin:cleanTest :micronaut-inject-kotlin:test \
  --tests "io.micronaut.kotlin.processing.beans.BeanDefinitionSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
