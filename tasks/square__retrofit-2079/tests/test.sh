#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableWithSchedulerTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableWithSchedulerTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableWithSchedulerTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableWithSchedulerTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/HttpExceptionTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/HttpExceptionTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeWithSchedulerTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeWithSchedulerTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableWithSchedulerTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableWithSchedulerTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingCompletableObserver.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingCompletableObserver.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingMaybeObserver.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingMaybeObserver.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingObserver.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingObserver.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingSingleObserver.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingSingleObserver.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingSubscriber.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RecordingSubscriber.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ResultTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ResultTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RxJavaPluginsResetRule.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/RxJavaPluginsResetRule.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/StringConverterFactory.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/StringConverterFactory.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleWithSchedulerTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleWithSchedulerTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=CompletableTest,CompletableThrowingTest,CompletableWithSchedulerTest,FlowableTest,FlowableThrowingTest,FlowableWithSchedulerTest,HttpExceptionTest,MaybeTest,MaybeThrowingTest,MaybeWithSchedulerTest,ObservableTest,ObservableThrowingTest,ObservableWithSchedulerTest,ResultTest,SingleTest,SingleThrowingTest,SingleWithSchedulerTest -pl retrofit-adapters/rxjava2
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
