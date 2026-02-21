#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ser"
cp "/tests/java/tools/jackson/databind/ser/ValueSerializerModifier5414Test.java" "src/test/java/tools/jackson/databind/ser/ValueSerializerModifier5414Test.java"

# Recompile test classes to pick up the restored test file and any patched source
mvn -B -ff -ntp test-compile -DskipTests

# Run only the specific test from this PR
mvn -B -ff -ntp test -Dtest=ValueSerializerModifier5414Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
