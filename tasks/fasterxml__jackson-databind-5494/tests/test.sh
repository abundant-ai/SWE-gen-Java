#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/BuilderWithBackRef2686Test.java" "src/test/java/tools/jackson/databind/struct/BuilderWithBackRef2686Test.java"

# Remove the tofix version if it exists (bug.patch moves the test there)
rm -f "src/test/java/tools/jackson/databind/tofix/BuilderWithBackRef2686Test.java"

# Run only the struct package version of the test
mvn -B -ntp test -Dtest="tools.jackson.databind.struct.BuilderWithBackRef2686Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
