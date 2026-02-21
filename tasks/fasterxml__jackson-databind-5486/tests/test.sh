#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/BackReference1516Test.java" "src/test/java/tools/jackson/databind/struct/BackReference1516Test.java"
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/Kotlin129ManagedReferenceTest.java" "src/test/java/tools/jackson/databind/struct/Kotlin129ManagedReferenceTest.java"

# Run only the specific test classes from this PR
mvn test -B -ff -ntp \
  -Dtest="tools.jackson.databind.struct.BackReference1516Test,tools.jackson.databind.struct.Kotlin129ManagedReferenceTest" \
  -DfailIfNoTests=false

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
