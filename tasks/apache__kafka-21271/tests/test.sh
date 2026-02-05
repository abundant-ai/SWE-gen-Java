#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/OffsetMetadataManagerTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/OffsetMetadataManagerTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.GroupCoordinatorServiceTest \
  --tests org.apache.kafka.coordinator.group.GroupCoordinatorShardTest \
  --tests org.apache.kafka.coordinator.group.OffsetMetadataManagerTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
