#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupMetadataManagerTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupMetadataManagerTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/classic"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/classic/ClassicGroupTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/classic/ClassicGroupTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer/ConsumerGroupTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer/ConsumerGroupTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/streams"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/streams/StreamsGroupTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/streams/StreamsGroupTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.GroupCoordinatorShardTest \
  --tests org.apache.kafka.coordinator.group.GroupMetadataManagerTest \
  --tests org.apache.kafka.coordinator.group.classic.ClassicGroupTest \
  --tests org.apache.kafka.coordinator.group.modern.consumer.ConsumerGroupTest \
  --tests org.apache.kafka.coordinator.group.streams.StreamsGroupTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
