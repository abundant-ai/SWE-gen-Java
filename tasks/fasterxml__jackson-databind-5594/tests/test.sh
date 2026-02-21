#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/DeserializationContextTest.java" "src/test/java/tools/jackson/databind/DeserializationContextTest.java"
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectReaderTest.java" "src/test/java/tools/jackson/databind/ObjectReaderTest.java"
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectWriterTest.java" "src/test/java/tools/jackson/databind/ObjectWriterTest.java"
mkdir -p "src/test/java/tools/jackson/databind/introspect"
cp "/tests/java/tools/jackson/databind/introspect/IntrospectorPairTest.java" "src/test/java/tools/jackson/databind/introspect/IntrospectorPairTest.java"

./mvnw -B -ntp test -Dtest=DeserializationContextTest,ObjectReaderTest,ObjectWriterTest,IntrospectorPairTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
