#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/misc"
cp "/tests/java/com/fasterxml/jackson/databind/misc/IPhoneStyleProperty5292Test.java" "src/test/java/com/fasterxml/jackson/databind/misc/IPhoneStyleProperty5292Test.java"

# Run only the specific test
mvn test -Dtest=IPhoneStyleProperty5292Test -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
