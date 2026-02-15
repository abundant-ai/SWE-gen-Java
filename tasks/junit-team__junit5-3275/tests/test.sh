#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerContextTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerContextTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerDeclarationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerDeclarationTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test --tests org.junit.jupiter.engine.config.CachingJupiterConfigurationTests \
    --tests org.junit.jupiter.engine.config.DefaultJupiterConfigurationTests \
    --tests org.junit.jupiter.engine.extension.CloseablePathCleanupTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryPerContextTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryPerDeclarationTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
