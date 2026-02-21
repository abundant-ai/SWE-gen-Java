#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/SetterlessPropertiesDeserTest.java" "src/test/java/tools/jackson/databind/deser/SetterlessPropertiesDeserTest.java"
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/WithoutParamNamesModule5314Test.java" "src/test/java/tools/jackson/databind/deser/WithoutParamNamesModule5314Test.java"

# Run only the specific test classes from this PR
mvn -B -ntp test -Dtest="SetterlessPropertiesDeserTest,WithoutParamNamesModule5314Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
