#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ext/cglib"
cp "/tests/java/tools/jackson/databind/ext/cglib/CglibFiltering5354Test.java" "src/test/java/tools/jackson/databind/ext/cglib/CglibFiltering5354Test.java"

# Recompile test classes after copying updated test file
mvn -B -ntp test-compile -DskipTests

# Run only the specific test class from this PR
mvn -B -ntp test -Dtest=CglibFiltering5354Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
