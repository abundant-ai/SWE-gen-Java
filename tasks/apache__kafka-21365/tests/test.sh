#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "streams/integration-tests/src/test/java/org/apache/kafka/streams/integration"
cp "/tests/streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/KafkaStreamsWrapper.java" "streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/KafkaStreamsWrapper.java"
mkdir -p "streams/integration-tests/src/test/java/org/apache/kafka/streams/integration"
cp "/tests/streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/RebalanceTaskClosureIntegrationTest.java" "streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/RebalanceTaskClosureIntegrationTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/processor/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/processor/internals/TaskManagerTest.java" "streams/src/test/java/org/apache/kafka/streams/processor/internals/TaskManagerTest.java"
mkdir -p "streams/src/test/java/org/apache/kafka/streams/processor/internals"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/processor/internals/TasksTest.java" "streams/src/test/java/org/apache/kafka/streams/processor/internals/TasksTest.java"

# Rebuild test classes to pick up the changes
./gradlew :streams:testClasses :streams:integration-tests:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR (run each module separately)
./gradlew :streams:test \
    --tests org.apache.kafka.streams.processor.internals.TaskManagerTest \
    --tests org.apache.kafka.streams.processor.internals.TasksTest \
    --no-daemon --no-configuration-cache 2>&1
streams_status=$?

./gradlew :streams:integration-tests:test \
    --tests org.apache.kafka.streams.integration.KafkaStreamsWrapper \
    --tests org.apache.kafka.streams.integration.RebalanceTaskClosureIntegrationTest \
    --no-daemon --no-configuration-cache 2>&1
streams_integration_status=$?

# Check if both tests passed
if [ $streams_status -eq 0 ] && [ $streams_integration_status -eq 0 ]; then
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
