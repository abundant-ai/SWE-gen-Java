#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/objectid"
cp "/tests/java/tools/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java" "src/test/java/tools/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java"

# Recompile test sources to pick up the updated test file
./mvnw -B -ff -ntp test-compile -DskipTests 2>&1

# Run only the specific test class from this PR
./mvnw -B -ff -ntp test -Dtest=ObjectIdInObjectArray5413Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
