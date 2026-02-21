#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/objectid"
cp "/tests/java/com/fasterxml/jackson/databind/objectid/ObjectIdWithReader5542Test.java" "src/test/java/com/fasterxml/jackson/databind/objectid/ObjectIdWithReader5542Test.java"

mvn -B -ntp test -Dtest=ObjectIdWithReader5542Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
