#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/DoubleNodeToInt5309Test.java" "src/test/java/tools/jackson/databind/node/DoubleNodeToInt5309Test.java"

# Run only the specific test class from this PR
./mvnw -B -ff -ntp test -Dtest=DoubleNodeToInt5309Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
