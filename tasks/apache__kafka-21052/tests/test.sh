#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime"
cp "/tests/coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/KRaftCoordinatorMetadataDeltaTest.java" "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/KRaftCoordinatorMetadataDeltaTest.java"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java"

# Rebuild test classes to pick up the changes
./gradlew :coordinator-common:testClasses :group-coordinator:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest 2>&1

# Run the specific test classes from this PR
./gradlew :coordinator-common:test :group-coordinator:test \
    --tests org.apache.kafka.coordinator.common.runtime.KRaftCoordinatorMetadataDeltaTest \
    --tests org.apache.kafka.coordinator.group.GroupCoordinatorServiceTest \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest -x checkstyleMain -x spotbugsMain 2>&1

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
