#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "server/src/test/java/org/apache/kafka/server"
cp "/tests/server/src/test/java/org/apache/kafka/server/BootstrapControllersIntegrationTest.java" "server/src/test/java/org/apache/kafka/server/BootstrapControllersIntegrationTest.java"

# Rebuild test classes to pick up the changes
./gradlew :server:testClasses \
    --no-daemon --no-configuration-cache --no-parallel --max-workers=1 \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" \
    -Dorg.gradle.workers.max=1 \
    -x checkstyleTest -x spotbugsTest 2>&1

# Run the specific test class from this PR
./gradlew :server:test \
    --tests org.apache.kafka.server.BootstrapControllersIntegrationTest \
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
