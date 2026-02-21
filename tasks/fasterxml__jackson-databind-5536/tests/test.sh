#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ser/filter"
cp "/tests/java/tools/jackson/databind/ser/filter/JsonIncludeForArray5515Test.java" "src/test/java/tools/jackson/databind/ser/filter/JsonIncludeForArray5515Test.java"

# Compile and run only the specific test class
mvn -B -ntp test -Dtest=JsonIncludeForArray5515Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
