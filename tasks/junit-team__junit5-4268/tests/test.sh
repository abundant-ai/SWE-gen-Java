#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesOnSubClassScenarioOneTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesOnSubClassScenarioOneTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesOnSubClassTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/IndicativeSentencesOnSubClassTestCase.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/support"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/support/AnnotationSupportTests.java" "platform-tests/src/test/java/org/junit/platform/commons/support/AnnotationSupportTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR (from jupiter-tests project)
echo "Running jupiter-tests..."
./gradlew :jupiter-tests:test --tests org.junit.jupiter.api.DisplayNameGenerationTests \
    --tests org.junit.jupiter.api.IndicativeSentencesOnSubClassScenarioOneTestCase \
    --tests org.junit.jupiter.api.IndicativeSentencesOnSubClassTestCase \
    --no-daemon --no-configuration-cache 2>&1
jupiter_status=$?
echo "Jupiter tests exit status: $jupiter_status"

# Run the specific test classes for this PR (from platform-tests project)
echo "Running platform-tests..."
./gradlew :platform-tests:test --tests org.junit.platform.commons.support.AnnotationSupportTests \
    --no-daemon --no-configuration-cache 2>&1
platform_status=$?
echo "Platform tests exit status: $platform_status"

# Check if both test runs passed
if [ $jupiter_status -eq 0 ] && [ $platform_status -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
