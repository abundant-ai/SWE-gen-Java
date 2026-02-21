#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/RequiredAccessorTest.java" "src/test/java/tools/jackson/databind/node/RequiredAccessorTest.java"
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/TreeBuildingGeneratorTest.java" "src/test/java/tools/jackson/databind/node/TreeBuildingGeneratorTest.java"

# Run only the specific test classes from the PR
mvn -B -ntp test -Dtest="RequiredAccessorTest,TreeBuildingGeneratorTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
