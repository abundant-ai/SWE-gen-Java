#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/JsonIncludeNonDefaultOnRecord5312Test.java" "src/test/java/tools/jackson/databind/records/JsonIncludeNonDefaultOnRecord5312Test.java"

# Run only the specific test class from this PR (use full class name to avoid picking up tofix variant)
mvn -B -ntp test -Dtest="tools.jackson.databind.records.JsonIncludeNonDefaultOnRecord5312Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
