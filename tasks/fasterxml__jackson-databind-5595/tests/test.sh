#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/std"
cp "/tests/java/tools/jackson/databind/deser/std/FunctionalScalarDeserializer4004Test.java" "src/test/java/tools/jackson/databind/deser/std/FunctionalScalarDeserializer4004Test.java"

mvn -B -ntp test -Dtest=FunctionalScalarDeserializer4004Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
