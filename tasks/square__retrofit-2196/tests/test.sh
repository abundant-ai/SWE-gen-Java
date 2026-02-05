#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/guava/src/test/java/retrofit2/adapter/guava"
cp "/tests/retrofit-adapters/guava/src/test/java/retrofit2/adapter/guava/ListenableFutureTest.java" "retrofit-adapters/guava/src/test/java/retrofit2/adapter/guava/ListenableFutureTest.java"
mkdir -p "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8"
cp "/tests/retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/CompletableFutureTest.java" "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/CompletableFutureTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/CompletableTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/HttpExceptionTest.java" "retrofit/src/test/java/retrofit2/HttpExceptionTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=ListenableFutureTest -pl retrofit-adapters/guava && \
mvn test -Dtest=CompletableFutureTest -pl retrofit-adapters/java8 && \
mvn test -Dtest=CompletableTest,ObservableTest,SingleTest -pl retrofit-adapters/rxjava && \
mvn test -Dtest=CompletableTest,FlowableTest,MaybeTest,ObservableTest,SingleTest -pl retrofit-adapters/rxjava2 && \
mvn test -Dtest=HttpExceptionTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
