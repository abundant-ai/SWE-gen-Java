#!/bin/bash

cd /app/src

# No additional environment variables needed for Gradle tests

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime"
cp "/tests/coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorExecutorImplTest.java" "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorExecutorImplTest.java"
mkdir -p "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime"
cp "/tests/coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorTimerImplTest.java" "coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/CoordinatorTimerImplTest.java"

# Run the specific test classes (gradle will automatically recompile changed sources)
./gradlew --no-daemon :coordinator-common:test --tests CoordinatorExecutorImplTest --tests CoordinatorTimerImplTest -x checkstyleMain -x checkstyleTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
