#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/convert"
cp "/tests/java/tools/jackson/databind/convert/MapConversion4878Test.java" "src/test/java/tools/jackson/databind/convert/MapConversion4878Test.java"
mkdir -p "src/test/java/tools/jackson/databind/convert"
cp "/tests/java/tools/jackson/databind/convert/StringConversionsTest.java" "src/test/java/tools/jackson/databind/convert/StringConversionsTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ext/xml"
cp "/tests/java/tools/jackson/databind/ext/xml/DOMElementWithCustomSerializerTest.java" "src/test/java/tools/jackson/databind/ext/xml/DOMElementWithCustomSerializerTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser"
cp "/tests/java/tools/jackson/databind/ser/CustomSerializersTest.java" "src/test/java/tools/jackson/databind/ser/CustomSerializersTest.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test -Dtest="MapConversion4878Test,StringConversionsTest,DOMElementWithCustomSerializerTest,CustomSerializersTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
