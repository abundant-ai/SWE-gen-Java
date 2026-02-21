#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/format"
cp "/tests/java/tools/jackson/databind/format/MapEntryFormat1419Test.java" "src/test/java/tools/jackson/databind/format/MapEntryFormat1419Test.java"

# Run only the specific test class
./mvnw -B -ff -ntp test -Dtest=MapEntryFormat1419Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
