#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/src/test/java/org/apache/kafka/clients/admin/internals"
cp "/tests/clients/src/test/java/org/apache/kafka/clients/admin/internals/PartitionLeaderStrategyIntegrationTest.java" "clients/src/test/java/org/apache/kafka/clients/admin/internals/PartitionLeaderStrategyIntegrationTest.java"
mkdir -p "core/src/test/java/kafka/admin"
cp "/tests/core/src/test/java/kafka/admin/ConcurrentListOffsetsRequestTest.java" "core/src/test/java/kafka/admin/ConcurrentListOffsetsRequestTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
# Run both tests but allow individual failures to be tracked
./gradlew --no-daemon \
  :clients:test --tests org.apache.kafka.clients.admin.internals.PartitionLeaderStrategyIntegrationTest \
  :core:test --tests kafka.admin.ConcurrentListOffsetsRequestTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
