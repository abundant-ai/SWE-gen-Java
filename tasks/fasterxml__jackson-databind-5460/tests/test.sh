#!/bin/bash

cd /app/src

# Remove the tofix/ version that was moved there by bug.patch (has @JacksonTestFailureExpected)
# This ensures only the correct HEAD version in interop/ is used
rm -f "src/test/java/tools/jackson/databind/tofix/KotlinIssue308JsonIgnoreTest.java"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/interop"
cp "/tests/java/tools/jackson/databind/interop/KotlinIssue308JsonIgnoreTest.java" "src/test/java/tools/jackson/databind/interop/KotlinIssue308JsonIgnoreTest.java"
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/RecordBasicsTest.java" "src/test/java/tools/jackson/databind/records/RecordBasicsTest.java"

# Run only the specific test classes from this PR
mvn -B -ff -ntp test -Dtest="KotlinIssue308JsonIgnoreTest,RecordBasicsTest" -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
