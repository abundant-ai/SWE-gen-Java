#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/filter"
cp "/tests/java/tools/jackson/databind/deser/filter/IgnoreUnknownPropertyUsingPropertyBasedTest.java" "src/test/java/tools/jackson/databind/deser/filter/IgnoreUnknownPropertyUsingPropertyBasedTest.java"
mkdir -p "src/test/java/tools/jackson/databind/objectid"
cp "/tests/java/tools/jackson/databind/objectid/JsonIdentityInfoAndBackReferences3964Test.java" "src/test/java/tools/jackson/databind/objectid/JsonIdentityInfoAndBackReferences3964Test.java"
mkdir -p "src/test/java/tools/jackson/databind/records"
cp "/tests/java/tools/jackson/databind/records/DuplicatePropertyDeserializationRecord4690Test.java" "src/test/java/tools/jackson/databind/records/DuplicatePropertyDeserializationRecord4690Test.java"

# Remove the "tofix" versions of these tests that were created by bug.patch.
# These have @JacksonTestFailureExpected and conflict with the fixed test files.
rm -f "src/test/java/tools/jackson/databind/tofix/JsonIdentityInfoAndBackReferences3964Test.java"
rm -f "src/test/java/tools/jackson/databind/records/tofix/DuplicatePropertyDeserializationRecord4690Test.java"

./mvnw -B -ntp test \
  -Dtest="IgnoreUnknownPropertyUsingPropertyBasedTest,JsonIdentityInfoAndBackReferences3964Test,DuplicatePropertyDeserializationRecord4690Test" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
