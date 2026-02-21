#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/format"
cp "/tests/java/tools/jackson/databind/format/MapFormatShape5405Test.java" "src/test/java/tools/jackson/databind/format/MapFormatShape5405Test.java"

# Recompile test sources to pick up updated test file
mvn -B test-compile -DskipTests -q

# Run only the specific test class from the PR using fully qualified name to avoid
# running the duplicate in the tofix package
mvn -B test -Dtest="tools.jackson.databind.format.MapFormatShape5405Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
