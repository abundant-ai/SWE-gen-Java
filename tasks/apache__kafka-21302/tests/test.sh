#!/bin/bash

cd /app/src

# No additional environment variables needed for Gradle tests

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/unit/kafka/network"
cp "/tests/core/src/test/scala/unit/kafka/network/ConnectionQuotasTest.scala" "core/src/test/scala/unit/kafka/network/ConnectionQuotasTest.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/DynamicBrokerConfigTest.scala" "core/src/test/scala/unit/kafka/server/DynamicBrokerConfigTest.scala"
mkdir -p "server/src/test/java/org/apache/kafka/server/config"
cp "/tests/server/src/test/java/org/apache/kafka/server/config/DynamicBrokerConfigTest.java" "server/src/test/java/org/apache/kafka/server/config/DynamicBrokerConfigTest.java"
mkdir -p "tools/src/test/java/org/apache/kafka/tools"
cp "/tests/tools/src/test/java/org/apache/kafka/tools/ConfigCommandIntegrationTest.java" "tools/src/test/java/org/apache/kafka/tools/ConfigCommandIntegrationTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :core:test --tests kafka.network.ConnectionQuotasTest --tests kafka.server.DynamicBrokerConfigTest \
  :server:test --tests org.apache.kafka.server.config.DynamicBrokerConfigTest \
  :tools:test --tests org.apache.kafka.tools.ConfigCommandIntegrationTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
