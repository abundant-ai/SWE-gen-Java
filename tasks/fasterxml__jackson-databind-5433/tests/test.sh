#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordsWithJsonIncludeAndIgnorals4629Test.java" "src/test/java/tools/jackson/databind/records/RecordsWithJsonIncludeAndIgnorals4629Test.java"

# Run only the specific test for this PR using fully qualified class name to avoid
# matching the tofix.RecordsWithJsonIncludeAndIgnorals4629Test variant
mvn test -Dtest="tools.jackson.databind.records.RecordsWithJsonIncludeAndIgnorals4629Test" -B -ntp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
