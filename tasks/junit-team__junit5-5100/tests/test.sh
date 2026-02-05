#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/TestMethodOverridingTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/TestMethodOverridingTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/subpackage"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/subpackage/SuperClassWithPackagePrivateLifecycleMethodInDifferentPackageTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/subpackage/SuperClassWithPackagePrivateLifecycleMethodInDifferentPackageTestCase.java"

# Run the specific tests for TestMethodOverridingTests and SuperClassWithPackagePrivateLifecycleMethodInDifferentPackageTestCase
./gradlew :jupiter-tests:test --tests "*TestMethodOverridingTests" --tests "*SuperClassWithPackagePrivateLifecycleMethodInDifferentPackageTestCase" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
