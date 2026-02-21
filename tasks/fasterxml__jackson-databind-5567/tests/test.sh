#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/convert"
cp "/tests/java/tools/jackson/databind/convert/CoerceEmptyArrayTest.java" "src/test/java/tools/jackson/databind/convert/CoerceEmptyArrayTest.java"
mkdir -p "src/test/java/tools/jackson/databind/convert"
cp "/tests/java/tools/jackson/databind/convert/DisableCoercions3690Test.java" "src/test/java/tools/jackson/databind/convert/DisableCoercions3690Test.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test -Dtest="CoerceEmptyArrayTest,DisableCoercions3690Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
