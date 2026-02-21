#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ext/javatime/deser"
cp "/tests/java/tools/jackson/databind/ext/javatime/deser/InstantDeserializerNegative359Test.java" "src/test/java/tools/jackson/databind/ext/javatime/deser/InstantDeserializerNegative359Test.java"

# Recompile test sources after copying HEAD test file
mvn -B test-compile -DskipTests 2>&1 | tail -5

# Run only the specific test class from this PR
mvn -B test -Dtest="tools.jackson.databind.ext.javatime.deser.InstantDeserializerNegative359Test" -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
