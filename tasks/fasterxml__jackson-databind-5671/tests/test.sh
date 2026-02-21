#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/BackRefWithPolymorphicContainer3304Test.java" "src/test/java/tools/jackson/databind/struct/BackRefWithPolymorphicContainer3304Test.java"

# Run only the specific test class
./mvnw -B -ff -ntp test -Dtest=BackRefWithPolymorphicContainer3304Test -pl .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
