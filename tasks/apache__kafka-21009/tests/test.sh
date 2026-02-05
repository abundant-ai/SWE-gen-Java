#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/KafkaApisTest.scala" "core/src/test/scala/unit/kafka/server/KafkaApisTest.scala"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorShardTest.java"
# Also copy PersisterStateManagerTest.java to avoid compilation errors in buggy state
mkdir -p "server-common/src/test/java/org/apache/kafka/server/share/persister"
cp "/tests/server-common/src/test/java/org/apache/kafka/server/share/persister/PersisterStateManagerTest.java" "server-common/src/test/java/org/apache/kafka/server/share/persister/PersisterStateManagerTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :core:unitTest --tests kafka.server.KafkaApisTest \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.GroupCoordinatorServiceTest \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.GroupCoordinatorShardTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
