#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/inject"
cp "/tests/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381DeserializationFeatureDisabledTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381DeserializationFeatureDisabledTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/inject"
cp "/tests/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381WithOptionalDeserializationFeatureDisabledTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381WithOptionalDeserializationFeatureDisabledTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/inject"
cp "/tests/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381WithOptionalTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject1381WithOptionalTest.java"

# Run only the specific test classes from this PR
./mvnw -B -ntp test \
  -Dtest="JacksonInject1381DeserializationFeatureDisabledTest,JacksonInject1381WithOptionalDeserializationFeatureDisabledTest,JacksonInject1381WithOptionalTest" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
