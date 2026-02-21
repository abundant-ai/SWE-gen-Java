#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser"
cp "/tests/java/com/fasterxml/jackson/databind/deser/JsonDeserializeAsTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/JsonDeserializeAsTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser"
cp "/tests/java/com/fasterxml/jackson/databind/deser/ValueAnnotationsDeserTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/ValueAnnotationsDeserTest.java"

# Run only the specific test classes from this PR
mvn -B -ntp test -Dtest="com.fasterxml.jackson.databind.deser.JsonDeserializeAsTest,com.fasterxml.jackson.databind.deser.ValueAnnotationsDeserTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
