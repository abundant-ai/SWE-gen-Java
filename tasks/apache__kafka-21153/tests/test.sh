#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/scala/kafka/server"
cp "/tests/core/src/test/scala/kafka/server/LocalLeaderEndPointTest.scala" "core/src/test/scala/kafka/server/LocalLeaderEndPointTest.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/AbstractFetcherManagerTest.scala" "core/src/test/scala/unit/kafka/server/AbstractFetcherManagerTest.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/MockFetcherThread.scala" "core/src/test/scala/unit/kafka/server/MockFetcherThread.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/MockLeaderEndPoint.scala" "core/src/test/scala/unit/kafka/server/MockLeaderEndPoint.scala"
mkdir -p "core/src/test/scala/unit/kafka/server"
cp "/tests/core/src/test/scala/unit/kafka/server/ReplicaFetcherThreadTest.scala" "core/src/test/scala/unit/kafka/server/ReplicaFetcherThreadTest.scala"

# Rebuild test classes to pick up the changes (increase memory for Scala compilation)
./gradlew :core:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest 2>&1

# Run the specific test classes from this PR
./gradlew :core:test \
    --tests kafka.server.LocalLeaderEndPointTest \
    --tests kafka.server.AbstractFetcherManagerTest \
    --tests kafka.server.ReplicaFetcherThreadTest \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest -x checkstyleMain -x spotbugsMain 2>&1

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
