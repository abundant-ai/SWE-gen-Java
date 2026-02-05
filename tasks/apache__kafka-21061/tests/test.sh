#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/src/test/java/kafka/server/share"
cp "/tests/core/src/test/java/kafka/server/share/ShareFetchUtilsTest.java" "core/src/test/java/kafka/server/share/ShareFetchUtilsTest.java"
mkdir -p "core/src/test/java/kafka/server/share"
cp "/tests/core/src/test/java/kafka/server/share/SharePartitionTest.java" "core/src/test/java/kafka/server/share/SharePartitionTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
# Both test classes are in the core module
./gradlew --no-daemon \
  :core:test --tests kafka.server.share.ShareFetchUtilsTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest && \
./gradlew --no-daemon \
  :core:test --tests kafka.server.share.SharePartitionTest \
  -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
