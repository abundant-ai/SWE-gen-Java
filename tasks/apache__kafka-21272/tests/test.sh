#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/java/kafka/server"
cp "/tests/core/src/test/java/kafka/server/KRaftTopicCreatorTest.java" "core/src/test/java/kafka/server/KRaftTopicCreatorTest.java"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/AutoTopicCreationManagerTest.scala" "core/src/test/scala/unit/kafka/server/AutoTopicCreationManagerTest.scala"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon \
  :core:test --tests kafka.server.KRaftTopicCreatorTest --tests kafka.server.AutoTopicCreationManagerTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
