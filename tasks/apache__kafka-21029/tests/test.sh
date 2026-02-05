#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "share-coordinator/src/test/java/org/apache/kafka/coordinator/share"
cp "/tests/share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java" "share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java"

# Run the specific test class (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :share-coordinator:test --tests org.apache.kafka.coordinator.share.ShareCoordinatorServiceTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
