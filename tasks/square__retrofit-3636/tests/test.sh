#!/bin/bash

cd /app/src

export CI=true

# Clean Gradle cache to avoid version conflicts
rm -rf /root/.gradle/caches/

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/CompletableThrowingTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/FlowableThrowingTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/MaybeThrowingTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/ObservableThrowingTest.java"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleThrowingTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/SingleThrowingTest.java"
mkdir -p "retrofit-adapters/rxjava3/src/test/java/retrofit2/adapter/rxjava3"
cp "/tests/retrofit-adapters/rxjava3/src/test/java/retrofit2/adapter/rxjava3/FlowableTest.java" "retrofit-adapters/rxjava3/src/test/java/retrofit2/adapter/rxjava3/FlowableTest.java"

# Build the modules to ensure test code is compiled (especially important when oracle applies fix)
./gradlew :retrofit-adapters:rxjava2:build -x test --console=plain --no-daemon --stacktrace || true
./gradlew :retrofit-adapters:rxjava3:build -x test --console=plain --no-daemon --stacktrace || true

# Run tests for the specific test classes using Gradle
./gradlew :retrofit-adapters:rxjava2:test --tests "retrofit2.adapter.rxjava2.AsyncTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.CompletableThrowingTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.FlowableTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.FlowableThrowingTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.MaybeThrowingTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.ObservableThrowingTest.*" \
                                          --tests "retrofit2.adapter.rxjava2.SingleThrowingTest.*" \
          :retrofit-adapters:rxjava3:test --tests "retrofit2.adapter.rxjava3.FlowableTest.*" \
          --console=plain --no-daemon --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
