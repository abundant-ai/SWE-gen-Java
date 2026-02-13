#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/admin"
cp "/tests/clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/admin/ConcurrentListOffsetsRequestTest.java" "clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/admin/ConcurrentListOffsetsRequestTest.java"
mkdir -p "clients/src/test/java/org/apache/kafka/clients/admin/internals"
cp "/tests/clients/src/test/java/org/apache/kafka/clients/admin/internals/PartitionLeaderStrategyIntegrationTest.java" "clients/src/test/java/org/apache/kafka/clients/admin/internals/PartitionLeaderStrategyIntegrationTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :clients:clients-integration-tests:test --tests org.apache.kafka.clients.admin.ConcurrentListOffsetsRequestTest \
  :clients:test --tests org.apache.kafka.clients.admin.internals.PartitionLeaderStrategyIntegrationTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
