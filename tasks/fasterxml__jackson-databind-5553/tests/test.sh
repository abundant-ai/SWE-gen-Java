#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ser"
cp "/tests/java/tools/jackson/databind/ser/ValueSerializerModifierTest.java" "src/test/java/tools/jackson/databind/ser/ValueSerializerModifierTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/filter"
cp "/tests/java/tools/jackson/databind/ser/filter/MapInclusion1649Test.java" "src/test/java/tools/jackson/databind/ser/filter/MapInclusion1649Test.java"

# Run only the specific test classes from the PR using fully qualified names
./mvnw -B -ff -ntp test \
  -Dtest="tools.jackson.databind.ser.ValueSerializerModifierTest,tools.jackson.databind.ser.filter.MapInclusion1649Test" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
