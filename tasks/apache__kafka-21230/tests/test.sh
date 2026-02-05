#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "server/src/test/java/org/apache/kafka/server"
cp "/tests/server/src/test/java/org/apache/kafka/server/KRaftClusterTest.java" "server/src/test/java/org/apache/kafka/server/KRaftClusterTest.java"

# Run the specific test class (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :server:test --tests org.apache.kafka.server.KRaftClusterTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
