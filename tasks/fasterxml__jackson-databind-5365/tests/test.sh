#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/JDKAtomicTypesDeserTest.java" "src/test/java/tools/jackson/databind/deser/jdk/JDKAtomicTypesDeserTest.java"
mkdir -p "src/test/java/tools/jackson/databind/ext/jdk8"
cp "/tests/java/tools/jackson/databind/ext/jdk8/CreatorForOptionalTest.java" "src/test/java/tools/jackson/databind/ext/jdk8/CreatorForOptionalTest.java"

# Run only the specific test classes from the PR
./mvnw -B -ff -ntp test -Dtest="JDKAtomicTypesDeserTest,CreatorForOptionalTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
