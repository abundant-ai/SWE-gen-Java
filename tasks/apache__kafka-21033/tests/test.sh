#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/src/test/java/org/apache/kafka/clients/consumer/internals"
cp "/tests/clients/src/test/java/org/apache/kafka/clients/consumer/internals/ShareSessionHandlerTest.java" "clients/src/test/java/org/apache/kafka/clients/consumer/internals/ShareSessionHandlerTest.java"

# Run the specific test class (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :clients:test --tests org.apache.kafka.clients.consumer.internals.ShareSessionHandlerTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
