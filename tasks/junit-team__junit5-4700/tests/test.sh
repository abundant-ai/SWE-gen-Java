#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/NestedTestClassesTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/StaticNestedTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/StaticNestedTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/TopLevelNestedTestCase.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/TopLevelNestedTestCase.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicatesTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicatesTests.java"

# Run the specific test classes for this PR
./gradlew :jupiter-tests:test --tests org.junit.jupiter.engine.NestedTestClassesTests --tests org.junit.jupiter.engine.discovery.DiscoveryTests --tests org.junit.jupiter.engine.discovery.predicates.TestClassPredicatesTests --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
