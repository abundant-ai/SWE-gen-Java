#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicatesTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicatesTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/util"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/util/ReflectionUtilsTests.java" "platform-tests/src/test/java/org/junit/platform/commons/util/ReflectionUtilsTests.java"

# Recompile after copying the updated files
echo "==== Recompiling test classes after applying fix ===="
./gradlew --no-daemon testClasses --no-configuration-cache 2>&1 | tee /tmp/recompile.log
recompile_exit=${PIPESTATUS[0]}
echo "==== Recompilation exit code: $recompile_exit ===="

if [ $recompile_exit -ne 0 ]; then
  echo "==== Recompilation failed ===="
  tail -100 /tmp/recompile.log
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Run the specific test classes for this PR
echo "==== Running tests ===="
./gradlew --no-daemon \
  :jupiter-tests:test --tests org.junit.jupiter.engine.discovery.DiscoveryTests \
  :jupiter-tests:test --tests org.junit.jupiter.engine.discovery.predicates.TestClassPredicatesTests \
  :platform-tests:test --tests org.junit.platform.commons.util.ReflectionUtilsTests \
  --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
