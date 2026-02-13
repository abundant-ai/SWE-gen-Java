#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/KafkaConfigTest.scala" "core/src/test/scala/unit/kafka/server/KafkaConfigTest.scala"
mkdir -p "server/src/test/java/org/apache/kafka/server/config"
cp "/tests/server/src/test/java/org/apache/kafka/server/config/AbstractKafkaConfigTest.java" "server/src/test/java/org/apache/kafka/server/config/AbstractKafkaConfigTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :core:test --tests kafka.server.KafkaConfigTest \
  :server:test --tests org.apache.kafka.server.config.AbstractKafkaConfigTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
