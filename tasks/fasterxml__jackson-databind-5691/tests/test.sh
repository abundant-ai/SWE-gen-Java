#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/util"
cp "/tests/java/tools/jackson/databind/util/ByteBufferUtilsTest.java" "src/test/java/tools/jackson/databind/util/ByteBufferUtilsTest.java"

# Recompile tests after copying updated test file
mvn -B -ff -ntp test-compile -DskipTests

# Run only the specific test class from the PR
mvn -B -ff -ntp test -Dtest=tools.jackson.databind.util.ByteBufferUtilsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
