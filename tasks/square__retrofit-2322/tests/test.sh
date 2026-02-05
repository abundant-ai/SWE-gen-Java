#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/AsyncTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/AsyncTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableThrowingSafeSubscriberTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableThrowingSafeSubscriberTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableThrowingTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableThrowingSafeSubscriberTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableThrowingSafeSubscriberTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableThrowingTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleThrowingTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleThrowingTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=AsyncTest,CompletableThrowingSafeSubscriberTest,CompletableThrowingTest,ObservableThrowingSafeSubscriberTest,ObservableThrowingTest,SingleThrowingTest -pl retrofit-adapters/rxjava
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
