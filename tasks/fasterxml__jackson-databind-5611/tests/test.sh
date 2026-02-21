#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeAsContainerTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeAsContainerTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeConversionsTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeConversionsTest.java"

./mvnw -B -ntp test -Dtest="tools.jackson.databind.node.JsonNodeAsContainerTest,tools.jackson.databind.node.JsonNodeConversionsTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
