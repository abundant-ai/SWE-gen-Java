#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/UnwrappedEmptyAsNull1709Test.java" "src/test/java/tools/jackson/databind/struct/UnwrappedEmptyAsNull1709Test.java"
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/UnwrappedWithUnknown650Test.java" "src/test/java/tools/jackson/databind/struct/UnwrappedWithUnknown650Test.java"

./mvnw -B -ff -ntp test -Dtest="UnwrappedEmptyAsNull1709Test,UnwrappedWithUnknown650Test" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
