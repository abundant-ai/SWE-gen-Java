#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/consumer"
cp "/tests/clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/consumer/ShareConsumerTest.java" "clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/consumer/ShareConsumerTest.java"

# Rebuild test classes to pick up the changes
./gradlew :clients:clients-integration-tests:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx5g -Xss4m" \
    -x checkstyleTest -x spotbugsTest -x :core:compileTestScala -x :core:compileTestJava 2>&1

# Run the specific test class from this PR
./gradlew :clients:clients-integration-tests:test \
    --tests org.apache.kafka.clients.consumer.ShareConsumerTest \
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
