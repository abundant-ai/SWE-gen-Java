#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/MultiParamWildcard4147Test.java" "src/test/java/tools/jackson/databind/deser/MultiParamWildcard4147Test.java"
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/RecursiveWildcard4118Test.java" "src/test/java/tools/jackson/databind/deser/RecursiveWildcard4118Test.java"

# Use fully-qualified class names to avoid matching tests in the tofix package
mvn -B -ntp test -Dtest="tools.jackson.databind.deser.MultiParamWildcard4147Test,tools.jackson.databind.deser.RecursiveWildcard4118Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
