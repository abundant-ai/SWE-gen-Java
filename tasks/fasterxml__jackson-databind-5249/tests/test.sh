#!/bin/bash

cd /app/src

# Set Java options for faster test execution
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/convert"
cp "/tests/java/com/fasterxml/jackson/databind/convert/CoerceContainersTest.java" "src/test/java/com/fasterxml/jackson/databind/convert/CoerceContainersTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/jdk"
cp "/tests/java/com/fasterxml/jackson/databind/deser/jdk/ArrayDeserializationTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/jdk/ArrayDeserializationTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/ser/jdk"
cp "/tests/java/com/fasterxml/jackson/databind/ser/jdk/VectorsAsBinarySerTest.java" "src/test/java/com/fasterxml/jackson/databind/ser/jdk/VectorsAsBinarySerTest.java"

# Run ONLY the specific test files from the PR
./mvnw -B -ff -ntp test -Dtest=CoerceContainersTest,ArrayDeserializationTest,VectorsAsBinarySerTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
