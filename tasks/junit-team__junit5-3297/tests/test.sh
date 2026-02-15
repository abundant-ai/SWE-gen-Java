#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledIfConditionClassLoaderTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/DisabledIfConditionClassLoaderTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledIfConditionClassLoaderTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/condition/EnabledIfConditionClassLoaderTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/MethodArgumentsProviderTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/provider/MethodArgumentsProviderTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses :junit-jupiter-params:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test --tests org.junit.jupiter.api.condition.DisabledIfConditionClassLoaderTests \
    --tests org.junit.jupiter.api.condition.EnabledIfConditionClassLoaderTests \
    :junit-jupiter-params:test --tests org.junit.jupiter.params.provider.MethodArgumentsProviderTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
