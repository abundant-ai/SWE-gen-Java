#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/src/test/java/org/apache/kafka/common/requests"
cp "/tests/clients/src/test/java/org/apache/kafka/common/requests/OffsetFetchResponseTest.java" "clients/src/test/java/org/apache/kafka/common/requests/OffsetFetchResponseTest.java"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/OffsetFetchRequestTest.scala" "core/src/test/scala/unit/kafka/server/OffsetFetchRequestTest.scala"

# Run the specific test classes (gradle will automatically recompile changed sources)
# OffsetFetchResponseTest is in clients module, OffsetFetchRequestTest is in core module
./gradlew --no-daemon \
  :clients:test --tests org.apache.kafka.common.requests.OffsetFetchResponseTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest && \
./gradlew --no-daemon \
  :core:test --tests kafka.server.OffsetFetchRequestTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
