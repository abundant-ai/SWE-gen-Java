#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredKeyValueStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredKeyValueStoreTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredSessionStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredSessionStoreTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredWindowStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredWindowStoreTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :streams:test --tests org.apache.kafka.streams.state.internals.MeteredKeyValueStoreTest \
  --tests org.apache.kafka.streams.state.internals.MeteredSessionStoreTest \
  --tests org.apache.kafka.streams.state.internals.MeteredWindowStoreTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
