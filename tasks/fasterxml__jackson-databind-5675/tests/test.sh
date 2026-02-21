#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/exc"
cp "/tests/java/com/fasterxml/jackson/databind/exc/ExceptionDeserializationTest.java" "src/test/java/com/fasterxml/jackson/databind/exc/ExceptionDeserializationTest.java"

mvn -B -ff -ntp test -Dtest=ExceptionDeserializationTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
