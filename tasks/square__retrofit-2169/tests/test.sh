#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=AsyncTest,CompletableThrowingTest -pl retrofit-adapters/rxjava2
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
