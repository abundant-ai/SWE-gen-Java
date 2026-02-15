#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example"
cp "/tests/documentation/src/test/java/example/TempDirectoryDemo.java" "documentation/src/test/java/example/TempDirectoryDemo.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/CloseablePathCleanupTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerContextTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerContextTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerDeclarationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/TempDirectoryPerDeclarationTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test \
    --tests example.TempDirectoryDemo \
    --tests org.junit.jupiter.engine.extension.CloseablePathCleanupTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryPerContextTests \
    --tests org.junit.jupiter.engine.extension.TempDirectoryPerDeclarationTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
