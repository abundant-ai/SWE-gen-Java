#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/Base64DecodingTest.java" "src/test/java/tools/jackson/databind/deser/jdk/Base64DecodingTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeBigIntegerValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeBigIntegerValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeBooleanValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeBooleanValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeDecimalValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeDecimalValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeDoubleValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeDoubleValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeFloatValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeFloatValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeIntValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeIntValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeLongValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeLongValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeNumberValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeNumberValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeShortValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeShortValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeStringValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeStringValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/TreeTraversingParserTest.java" "src/test/java/tools/jackson/databind/node/TreeTraversingParserTest.java"

# Run only the specific test classes from this PR
mvn -B -ntp test \
  -Dtest="tools.jackson.databind.deser.jdk.Base64DecodingTest,tools.jackson.databind.node.JsonNodeBigIntegerValueTest,tools.jackson.databind.node.JsonNodeBooleanValueTest,tools.jackson.databind.node.JsonNodeDecimalValueTest,tools.jackson.databind.node.JsonNodeDoubleValueTest,tools.jackson.databind.node.JsonNodeFloatValueTest,tools.jackson.databind.node.JsonNodeIntValueTest,tools.jackson.databind.node.JsonNodeLongValueTest,tools.jackson.databind.node.JsonNodeNumberValueTest,tools.jackson.databind.node.JsonNodeShortValueTest,tools.jackson.databind.node.JsonNodeStringValueTest,tools.jackson.databind.node.TreeTraversingParserTest" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
