#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/MapperViaParserTest.java" "src/test/java/tools/jackson/databind/MapperViaParserTest.java"
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectMapperTest.java" "src/test/java/tools/jackson/databind/ObjectMapperTest.java"

# Run only the specific test classes from the PR
./mvnw -B -ntp test -Dtest="MapperViaParserTest,ObjectMapperTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
