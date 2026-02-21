#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectMapperTest.java" "src/test/java/tools/jackson/databind/ObjectMapperTest.java"
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectReaderTest.java" "src/test/java/tools/jackson/databind/ObjectReaderTest.java"
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectWriterTest.java" "src/test/java/tools/jackson/databind/ObjectWriterTest.java"
mkdir -p "src/test/java/tools/jackson/databind/contextual"
cp "/tests/java/tools/jackson/databind/contextual/ContextAttributeWithDeserTest.java" "src/test/java/tools/jackson/databind/contextual/ContextAttributeWithDeserTest.java"
mkdir -p "src/test/java/tools/jackson/databind/deser/validate"
cp "/tests/java/tools/jackson/databind/deser/validate/FullStreamReadTest.java" "src/test/java/tools/jackson/databind/deser/validate/FullStreamReadTest.java"
mkdir -p "src/test/java/tools/jackson/databind/jsonschema"
cp "/tests/java/tools/jackson/databind/jsonschema/NewSchemaTest.java" "src/test/java/tools/jackson/databind/jsonschema/NewSchemaTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeConversionsTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeConversionsTest.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test -Dtest="ObjectMapperTest,ObjectReaderTest,ObjectWriterTest,ContextAttributeWithDeserTest,FullStreamReadTest,NewSchemaTest,JsonNodeConversionsTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
