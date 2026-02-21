#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/CollectionDeserializer5522Test.java" "src/test/java/tools/jackson/databind/deser/jdk/CollectionDeserializer5522Test.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/NodeContext2049Test.java" "src/test/java/tools/jackson/databind/node/NodeContext2049Test.java"

# Run only the two specific test classes from this PR
./mvnw -B -ntp test \
  -Dtest="tools.jackson.databind.deser.jdk.CollectionDeserializer5522Test,tools.jackson.databind.node.NodeContext2049Test" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
