#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm"
cp "/tests/mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm/DummyObject.java" "mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm/DummyObject.java"
mkdir -p "mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm"
cp "/tests/mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm/GraalVMSubclassMockMakerTest.java" "mockito-integration-tests/graalvm-tests/src/test/java/org/mockito/graalvm/GraalVMSubclassMockMakerTest.java"

# Run the specific GraalVM test
./gradlew :mockito-integration-tests:graalvm-tests:test --tests org.mockito.graalvm.GraalVMSubclassMockMakerTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
