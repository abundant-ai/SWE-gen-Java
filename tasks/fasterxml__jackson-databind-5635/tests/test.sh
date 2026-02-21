#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/enums"
cp "/tests/java/tools/jackson/databind/deser/enums/EnumMapDeserializationTest.java" "src/test/java/tools/jackson/databind/deser/enums/EnumMapDeserializationTest.java"

mvn -B -ntp test -Dtest=EnumMapDeserializationTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
