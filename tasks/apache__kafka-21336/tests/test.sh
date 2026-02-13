#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/integration/kafka/server"
cp "/tests/core/src/test/scala/integration/kafka/server/FetchFromFollowerIntegrationTest.scala" "core/src/test/scala/integration/kafka/server/FetchFromFollowerIntegrationTest.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/BrokerLifecycleManagerTest.scala" "core/src/test/scala/unit/kafka/server/BrokerLifecycleManagerTest.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/DescribeClusterRequestTest.scala" "core/src/test/scala/unit/kafka/server/DescribeClusterRequestTest.scala"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon :core:test \
  --tests kafka.server.FetchFromFollowerIntegrationTest \
  --tests kafka.server.BrokerLifecycleManagerTest \
  --tests kafka.server.DescribeClusterRequestTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
