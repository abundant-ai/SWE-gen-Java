#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/jdk"
cp "/tests/java/com/fasterxml/jackson/databind/deser/jdk/DateRoundtrip5429Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/jdk/DateRoundtrip5429Test.java"

# Run only the specific test class from the PR
mvn -B -ntp test -Dtest=DateRoundtrip5429Test -Dsurefire.failIfNoSpecifiedTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
