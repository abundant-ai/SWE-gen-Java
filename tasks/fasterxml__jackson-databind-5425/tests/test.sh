#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/objectid"
cp "/tests/java/com/fasterxml/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java" "src/test/java/com/fasterxml/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java"

# Run only the specific test class from the PR
mvn -B -ntp test -Dtest=ObjectIdInObjectArray5413Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
