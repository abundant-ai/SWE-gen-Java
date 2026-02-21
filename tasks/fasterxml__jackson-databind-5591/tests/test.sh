#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/Base64DecodingTest.java" "src/test/java/tools/jackson/databind/deser/jdk/Base64DecodingTest.java"
mkdir -p "src/test/java/tools/jackson/databind/objectid"
cp "/tests/java/tools/jackson/databind/objectid/AbstractWithObjectIdTest.java" "src/test/java/tools/jackson/databind/objectid/AbstractWithObjectIdTest.java"
mkdir -p "src/test/java/tools/jackson/databind/objectid"
cp "/tests/java/tools/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java" "src/test/java/tools/jackson/databind/objectid/ObjectIdInObjectArray5413Test.java"
mkdir -p "src/test/java/tools/jackson/databind/objectid"
cp "/tests/java/tools/jackson/databind/objectid/ObjectIdReordering1388Test.java" "src/test/java/tools/jackson/databind/objectid/ObjectIdReordering1388Test.java"

# Run only the specific test classes from the PR
mvn -B -ntp test -Dtest="Base64DecodingTest,AbstractWithObjectIdTest,ObjectIdInObjectArray5413Test,ObjectIdReordering1388Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
