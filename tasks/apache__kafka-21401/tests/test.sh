#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/HeadersDeserializerTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/HeadersDeserializerTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/HeadersSerializerTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/HeadersSerializerTest.java"

# Rebuild test classes to pick up the changes
./gradlew :streams:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :streams:test \
    --tests org.apache.kafka.streams.state.internals.HeadersDeserializerTest \
    --tests org.apache.kafka.streams.state.internals.HeadersSerializerTest \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
