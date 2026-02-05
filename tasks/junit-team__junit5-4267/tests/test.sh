#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example/sharedresources"
cp "/tests/documentation/src/test/java/example/sharedresources/DynamicSharedResourcesDemo.java" "documentation/src/test/java/example/sharedresources/DynamicSharedResourcesDemo.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLockAnnotationTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLockAnnotationTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLocksProviderTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/parallel/ResourceLocksProviderTests.java"

# Rebuild test classes to pick up the changes
./gradlew testClasses --no-daemon --no-configuration-cache

# Run the specific test classes for this PR (from jupiter-tests project)
echo "Running jupiter-tests..."
./gradlew :jupiter-tests:test --tests org.junit.jupiter.api.parallel.ResourceLockAnnotationTests \
    --tests org.junit.jupiter.api.parallel.ResourceLocksProviderTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?
echo "Jupiter tests exit status: $test_status"

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
