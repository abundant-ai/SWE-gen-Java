#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/OffsetFetchRequestTest.scala" "core/src/test/scala/unit/kafka/server/OffsetFetchRequestTest.scala"
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/GroupCoordinatorServiceTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
# Run the tests separately since they're in different modules
./gradlew --no-daemon \
  :core:test --tests kafka.server.OffsetFetchRequestTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status_1=$?

./gradlew --no-daemon \
  :group-coordinator:test --tests org.apache.kafka.coordinator.group.GroupCoordinatorServiceTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status_2=$?

# Both tests must pass
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
