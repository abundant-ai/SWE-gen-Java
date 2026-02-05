#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/src/test/java/org/apache/kafka/clients/producer/internals"
cp "/tests/clients/src/test/java/org/apache/kafka/clients/producer/internals/RecordAccumulatorTest.java" "clients/src/test/java/org/apache/kafka/clients/producer/internals/RecordAccumulatorTest.java"
mkdir -p "clients/src/test/java/org/apache/kafka/clients/producer/internals"
cp "/tests/clients/src/test/java/org/apache/kafka/clients/producer/internals/SenderTest.java" "clients/src/test/java/org/apache/kafka/clients/producer/internals/SenderTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
# Both tests are in the clients module, so we can run them together
./gradlew --no-daemon \
  :clients:test --tests org.apache.kafka.clients.producer.internals.RecordAccumulatorTest \
  --tests org.apache.kafka.clients.producer.internals.SenderTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
