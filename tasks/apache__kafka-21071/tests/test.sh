#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/KafkaApisTest.scala" "core/src/test/scala/unit/kafka/server/KafkaApisTest.scala"
mkdir -p "server/src/test/java/org/apache/kafka/server/share/session"
cp "/tests/server/src/test/java/org/apache/kafka/server/share/session/ShareSessionCacheTest.java" "server/src/test/java/org/apache/kafka/server/share/session/ShareSessionCacheTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
# Note: Running tests from multiple modules requires running them separately
./gradlew --no-daemon \
  :core:test --tests kafka.server.KafkaApisTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
core_status=$?

./gradlew --no-daemon \
  :server:test --tests org.apache.kafka.server.share.session.ShareSessionCacheTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
server_status=$?

# Both tests must pass
if [ $core_status -eq 0 ] && [ $server_status -eq 0 ]; then
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
