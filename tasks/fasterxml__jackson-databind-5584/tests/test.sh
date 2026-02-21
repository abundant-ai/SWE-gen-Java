#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
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
cp "/tests/java/tools/jackson/databind/node/JsonNodeShortValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeShortValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeStringValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeStringValueTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/MissingNodeTest.java" "src/test/java/tools/jackson/databind/node/MissingNodeTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/POJONodeTest.java" "src/test/java/tools/jackson/databind/node/POJONodeTest.java"

# Run only the specific test classes from this PR
mvn -B -ntp test \
    -Dtest="JsonNodeBigIntegerValueTest,JsonNodeBooleanValueTest,JsonNodeDecimalValueTest,JsonNodeDoubleValueTest,JsonNodeFloatValueTest,JsonNodeIntValueTest,JsonNodeLongValueTest,JsonNodeShortValueTest,JsonNodeStringValueTest,MissingNodeTest,POJONodeTest" \
    -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
