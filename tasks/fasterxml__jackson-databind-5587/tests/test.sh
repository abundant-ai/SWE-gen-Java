#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/ArrayNodeTest.java" "src/test/java/tools/jackson/databind/node/ArrayNodeTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/TreeTraversingParserTest.java" "src/test/java/tools/jackson/databind/node/TreeTraversingParserTest.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test -Dtest="ArrayNodeTest,TreeTraversingParserTest" -Dsurefire.failIfNoSpecifiedTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
