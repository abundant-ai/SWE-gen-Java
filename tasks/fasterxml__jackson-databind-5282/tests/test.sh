#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/enums"
cp "/tests/java/com/fasterxml/jackson/databind/deser/enums/EnumDeserializerJsonValue5271Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/enums/EnumDeserializerJsonValue5271Test.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/ser/enums"
cp "/tests/java/com/fasterxml/jackson/databind/ser/enums/EnumAsMapKeyTest.java" "src/test/java/com/fasterxml/jackson/databind/ser/enums/EnumAsMapKeyTest.java"

# Run ONLY the specific test classes from the PR
./mvnw -B -ff -ntp test -Dtest=EnumDeserializerJsonValue5271Test,EnumAsMapKeyTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
