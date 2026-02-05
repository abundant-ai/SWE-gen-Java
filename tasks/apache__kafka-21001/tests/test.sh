#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/src/test/java/org/apache/kafka/common/utils"
cp "/tests/clients/src/test/java/org/apache/kafka/common/utils/ExponentialBackoffManagerTest.java" "clients/src/test/java/org/apache/kafka/common/utils/ExponentialBackoffManagerTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/NetworkPartitionMetadataClientTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/NetworkPartitionMetadataClientTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :clients:test --tests org.apache.kafka.common.utils.ExponentialBackoffManagerTest \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.NetworkPartitionMetadataClientTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
