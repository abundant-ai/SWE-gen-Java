#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/ObjectArrayDeserArrayStoreExc5646Test.java" \
   "src/test/java/tools/jackson/databind/deser/jdk/ObjectArrayDeserArrayStoreExc5646Test.java"

# Run only the specific test class for this PR
mvn -B -ntp test -Dtest=ObjectArrayDeserArrayStoreExc5646Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
