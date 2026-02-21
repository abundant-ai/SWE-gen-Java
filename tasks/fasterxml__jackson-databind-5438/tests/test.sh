#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/jsonschema"
cp "/tests/java/tools/jackson/databind/jsonschema/NewSchemaTest.java" "src/test/java/tools/jackson/databind/jsonschema/NewSchemaTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/enums"
cp "/tests/java/tools/jackson/databind/ser/enums/EnumNamingSerializationTest.java" "src/test/java/tools/jackson/databind/ser/enums/EnumNamingSerializationTest.java"
mkdir -p "src/test/java/tools/jackson/databind/util"
cp "/tests/java/tools/jackson/databind/util/EnumValuesTest.java" "src/test/java/tools/jackson/databind/util/EnumValuesTest.java"

./mvnw -B -ff -ntp test \
  -Dtest="tools.jackson.databind.jsonschema.NewSchemaTest,tools.jackson.databind.ser.enums.EnumNamingSerializationTest,tools.jackson.databind.util.EnumValuesTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
