#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestFactoryTestDescriptor.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestFactoryTestDescriptor.java"
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestMethodTestDescriptor.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestMethodTestDescriptor.java"
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestTemplateTestDescriptor.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestTemplateTestDescriptor.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeScenarioOneTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeScenarioOneTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeScenarioTwoTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeScenarioTwoTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesRuntimeEnclosingTypeTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLockAnnotationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLockAnnotationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/CustomDisplayNameGenerator.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/CustomDisplayNameGenerator.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/DisplayNameUtilsTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/DisplayNameUtilsTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/JupiterTestDescriptorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/JupiterTestDescriptorTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestFactoryTestDescriptorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestFactoryTestDescriptorTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestTemplateInvocationTestDescriptorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestTemplateInvocationTestDescriptorTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestTemplateTestDescriptorTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/TestTemplateTestDescriptorTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR (from jupiter-tests project)
echo "Running jupiter-tests..."
./gradlew :jupiter-tests:test --tests org.junit.jupiter.api.DisplayNameGenerationTests \
    --tests org.junit.jupiter.api.IndicativeSentencesRuntimeEnclosingTypeScenarioOneTestCase \
    --tests org.junit.jupiter.api.IndicativeSentencesRuntimeEnclosingTypeScenarioTwoTestCase \
    --tests org.junit.jupiter.api.IndicativeSentencesRuntimeEnclosingTypeTestCase \
    --tests org.junit.jupiter.api.parallel.ResourceLockAnnotationTests \
    --tests org.junit.jupiter.engine.descriptor.DisplayNameUtilsTests \
    --tests org.junit.jupiter.engine.descriptor.ExtensionContextTests \
    --tests org.junit.jupiter.engine.descriptor.JupiterTestDescriptorTests \
    --tests org.junit.jupiter.engine.descriptor.TestFactoryTestDescriptorTests \
    --tests org.junit.jupiter.engine.descriptor.TestTemplateInvocationTestDescriptorTests \
    --tests org.junit.jupiter.engine.descriptor.TestTemplateTestDescriptorTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?
echo "Jupiter tests exit status: $test_status"

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
