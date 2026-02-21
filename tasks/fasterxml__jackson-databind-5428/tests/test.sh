#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonPointerRemoval1981Test.java" "src/test/java/tools/jackson/databind/node/JsonPointerRemoval1981Test.java"

./mvnw -B -ff -ntp test -Dtest=JsonPointerRemoval1981Test -q
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
