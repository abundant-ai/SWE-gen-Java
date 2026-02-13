#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer"
cp "/tests/group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer/TopicRegexResolverTest.java" "group-coordinator/src/test/java/org/apache/kafka/coordinator/group/modern/consumer/TopicRegexResolverTest.java"

# Rebuild test classes to pick up the changes
./gradlew :group-coordinator:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest 2>&1

# Run the specific test class from this PR
./gradlew :group-coordinator:test \
    --tests org.apache.kafka.coordinator.group.modern.consumer.TopicRegexResolverTest \
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
