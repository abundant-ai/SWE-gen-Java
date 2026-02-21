#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/node"
cp "/tests/java/com/fasterxml/jackson/databind/node/ObjectNodeTest.java" "src/test/java/com/fasterxml/jackson/databind/node/ObjectNodeTest.java"

# Run only the specific test class from this PR
mvn -B -ntp test -Dtest=com.fasterxml.jackson.databind.node.ObjectNodeTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
