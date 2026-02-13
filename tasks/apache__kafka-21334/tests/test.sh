#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime"
cp "/tests/coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorExecutorImplTest.java" "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorExecutorImplTest.java"
mkdir -p "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime"
cp "/tests/coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRuntimeTest.java" "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRuntimeTest.java"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/KafkaApisTest.scala" "core/src/test/scala/unit/kafka/server/KafkaApisTest.scala"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java"
mkdir -p "share-coordinator/src/test/java/org/apache/kafka/coordinator/share"
cp "/tests/share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java" "share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon :coordinator-common:test \
  --tests org.apache.kafka.coordinator.common.runtime.CoordinatorExecutorImplTest \
  --tests org.apache.kafka.coordinator.common.runtime.CoordinatorRuntimeTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest && \
./gradlew --no-daemon :core:test \
  --tests kafka.server.KafkaApisTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest && \
./gradlew --no-daemon :group-coordinator:test \
  --tests org.apache.kafka.coordinator.group.GroupCoordinatorServiceTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest && \
./gradlew --no-daemon :share-coordinator:test \
  --tests org.apache.kafka.coordinator.share.ShareCoordinatorServiceTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
