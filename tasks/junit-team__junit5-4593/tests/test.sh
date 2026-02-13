#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java"

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
  :jupiter-tests:test --tests org.junit.jupiter.engine.descriptor.ExtensionContextTests \
  --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
