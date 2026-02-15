#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example"
cp "/tests/documentation/src/test/java/example/TempDirCleanupModeDemo.java" "documentation/src/test/java/example/TempDirCleanupModeDemo.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/DefaultExecutionCleanupModeTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/DefaultExecutionCleanupModeTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryCleanupTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryCleanupTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryParameterResolverTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryParameterResolverTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test :documentation:test \
    --tests example.TempDirCleanupModeDemo \
    --tests org.junit.jupiter.engine.DefaultExecutionCleanupModeTests \
    --tests org.junit.jupiter.engine.config.CachingJupiterConfigurationTests \
    --tests org.junit.jupiter.engine.config.DefaultJupiterConfigurationTests \
    --tests org.junit.jupiter.engine.extension.CloseablePathCleanupTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryCleanupTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryParameterResolverTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
