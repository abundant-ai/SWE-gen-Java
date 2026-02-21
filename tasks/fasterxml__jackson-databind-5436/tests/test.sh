#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/enums"
cp "/tests/java/tools/jackson/databind/deser/enums/EnumMapDeserializationTest.java" "src/test/java/tools/jackson/databind/deser/enums/EnumMapDeserializationTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/enums"
cp "/tests/java/tools/jackson/databind/ser/enums/EnumAsMapKeySerializationTest.java" "src/test/java/tools/jackson/databind/ser/enums/EnumAsMapKeySerializationTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/enums"
cp "/tests/java/tools/jackson/databind/ser/enums/EnumNamingSerializationTest.java" "src/test/java/tools/jackson/databind/ser/enums/EnumNamingSerializationTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/enums"
cp "/tests/java/tools/jackson/databind/ser/enums/EnumSerializationTest.java" "src/test/java/tools/jackson/databind/ser/enums/EnumSerializationTest.java"
mkdir -p "src/test/java/tools/jackson/databind/util"
cp "/tests/java/tools/jackson/databind/util/EnumValuesTest.java" "src/test/java/tools/jackson/databind/util/EnumValuesTest.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test \
  -Dtest="tools.jackson.databind.deser.enums.EnumMapDeserializationTest,tools.jackson.databind.ser.enums.EnumAsMapKeySerializationTest,tools.jackson.databind.ser.enums.EnumNamingSerializationTest,tools.jackson.databind.ser.enums.EnumSerializationTest,tools.jackson.databind.util.EnumValuesTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
