#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/introspect"
cp "/tests/java/com/fasterxml/jackson/databind/introspect/JsonPropertyRename5398Test.java" "src/test/java/com/fasterxml/jackson/databind/introspect/JsonPropertyRename5398Test.java"

# Run only the specific test class from the PR
mvn -B -ff -ntp test -Dtest=JsonPropertyRename5398Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
