#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "streams/src/test/java/org/apache/kafka/streams/processor/internals/metrics"
cp "/tests/streams/src/test/java/org/apache/kafka/streams/processor/internals/metrics/ThreadMetricsTest.java" "streams/src/test/java/org/apache/kafka/streams/processor/internals/metrics/ThreadMetricsTest.java"

# Rebuild test classes to pick up the changes
./gradlew :streams:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx5g -Xss4m" \
    -x checkstyleTest -x spotbugsTest -x :core:compileTestScala -x :core:compileTestJava 2>&1

# Run the specific test class from this PR
./gradlew :streams:test \
    --tests org.apache.kafka.streams.processor.internals.metrics.ThreadMetricsTest \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx5g -Xss4m" \
    -x checkstyleTest -x spotbugsTest -x checkstyleMain -x spotbugsMain \
    -x :core:compileTestScala -x :core:compileTestJava 2>&1

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
