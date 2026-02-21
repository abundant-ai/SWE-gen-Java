#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordViaParser5683Test.java" "src/test/java/tools/jackson/databind/records/RecordViaParser5683Test.java"
mkdir -p "src/test/java/tools/jackson/databind/ser/filter"
cp "/tests/java/tools/jackson/databind/ser/filter/JsonIncludeForArray5515Test.java" "src/test/java/tools/jackson/databind/ser/filter/JsonIncludeForArray5515Test.java"

# Recompile test sources to pick up the updated test files
./mvnw -B -ntp -DskipTests test-compile

# Run only the specific test classes from the PR
./mvnw -B -ntp test -Dtest="RecordViaParser5683Test,JsonIncludeForArray5515Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
