#!/bin/bash

cd /app/src

# Remove OpenIteratorsTest.java if it exists (orphaned test from buggy state)
# This test depends on OpenIterators class which is deleted by the fix
rm -f streams/src/test/java/org/apache/kafka/streams/internals/metrics/OpenIteratorsTest.java

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredKeyValueStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredKeyValueStoreTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredTimestampedKeyValueStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredTimestampedKeyValueStoreTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/state/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredVersionedKeyValueStoreTest.java" "streams/src/test/java/org/apache/kafka/streams/state/internals/MeteredVersionedKeyValueStoreTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :streams:test --tests org.apache.kafka.streams.state.internals.MeteredKeyValueStoreTest \
  --tests org.apache.kafka.streams.state.internals.MeteredTimestampedKeyValueStoreTest \
  --tests org.apache.kafka.streams.state.internals.MeteredVersionedKeyValueStoreTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
