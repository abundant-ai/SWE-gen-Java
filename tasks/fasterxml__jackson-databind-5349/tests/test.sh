#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ext/jdk8"
cp "/tests/java/tools/jackson/databind/ext/jdk8/CreatorForOptionalTest.java" "src/test/java/tools/jackson/databind/ext/jdk8/CreatorForOptionalTest.java"

mvn -B -ntp test-compile -q
mvn -B -ntp test -Dtest=CreatorForOptionalTest -pl . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
