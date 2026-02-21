#!/bin/bash

cd /app/src

# No additional environment variables needed for tests

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectMapperTest.java" "src/test/java/tools/jackson/databind/ObjectMapperTest.java"
mkdir -p "src/test/java/tools/jackson/databind/records/tofix"
cp "/tests/java/tools/jackson/databind/records/tofix/JsonIdentityOnRecord5238Test.java" "src/test/java/tools/jackson/databind/records/tofix/JsonIdentityOnRecord5238Test.java"

# Compile and run ONLY the specific test classes from the PR
# Use fully qualified class names to avoid running unintended tests
./mvnw -B -ff -ntp test-compile test -Dtest=tools.jackson.databind.ObjectMapperTest,tools.jackson.databind.records.tofix.JsonIdentityOnRecord5238Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
