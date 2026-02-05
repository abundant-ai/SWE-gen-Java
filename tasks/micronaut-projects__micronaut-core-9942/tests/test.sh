#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/configproperties"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/configproperties/ConfigurationPropertiesBuilderSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/configproperties/ConfigurationPropertiesBuilderSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/configproperties"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/configproperties/InheritedConfigurationReaderPrefixSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/configproperties/InheritedConfigurationReaderPrefixSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/visitor/PropertyElementSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/visitor/PropertyElementSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/annotation/JavaAnnotationMetadataBuilderSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/annotation/JavaAnnotationMetadataBuilderSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/annotation/MyStereotypeWithDefaultValue.java" "inject-java/src/test/groovy/io/micronaut/inject/annotation/MyStereotypeWithDefaultValue.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configproperties"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configproperties/ConfigurationPropertiesBuilderSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configproperties/ConfigurationPropertiesBuilderSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/configproperties"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/configproperties/InheritedConfigurationReaderPrefixSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/configproperties/InheritedConfigurationReaderPrefixSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/PropertyElementSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/PropertyElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-groovy/src/test/groovy/io/micronaut/inject/configproperties/*.groovy 2>/dev/null || true
touch inject-groovy/src/test/groovy/io/micronaut/inject/visitor/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/annotation/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/annotation/*.java 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/configproperties/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/visitors/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-groovy/build/classes/ 2>/dev/null || true
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually
test_output=$(./gradlew \
    :inject-groovy:test --tests "*ConfigurationPropertiesBuilderSpec*" --tests "*InheritedConfigurationReaderPrefixSpec*" --tests "*PropertyElementSpec*" \
    :inject-java:test --tests "*JavaAnnotationMetadataBuilderSpec*" --tests "*ConfigurationPropertiesBuilderSpec*" --tests "*InheritedConfigurationReaderPrefixSpec*" --tests "*PropertyElementSpec*" \
    --no-daemon --console=plain 2>&1)
gradle_exit=$?
set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    test_status=$gradle_exit
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
