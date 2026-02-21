#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ext/javatime/deser"
cp "/tests/java/tools/jackson/databind/ext/javatime/deser/InstantDeserTest.java" "src/test/java/tools/jackson/databind/ext/javatime/deser/InstantDeserTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ext/javatime/deser"
cp "/tests/java/tools/jackson/databind/ext/javatime/deser/LocalDateDeserTest.java" "src/test/java/tools/jackson/databind/ext/javatime/deser/LocalDateDeserTest.java"

# Run only the specific test classes from this PR
./mvnw -B -ff -ntp test -Dtest="InstantDeserTest,LocalDateDeserTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
