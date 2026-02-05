#!/bin/bash

cd /app/src

# No special environment variables needed

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "android/guava-tests/test/com/google/common/eventbus"
cp "/tests/android/guava-tests/test/com/google/common/eventbus/EventBusTest.java" "android/guava-tests/test/com/google/common/eventbus/EventBusTest.java"
mkdir -p "guava-tests/test/com/google/common/eventbus"
cp "/tests/guava-tests/test/com/google/common/eventbus/EventBusTest.java" "guava-tests/test/com/google/common/eventbus/EventBusTest.java"

# Recompile test classes after copying (required for Java)
./mvnw -B test-compile -Dmaven.javadoc.skip=true -pl guava-tests
./mvnw -B test-compile -Dmaven.javadoc.skip=true -f android/pom.xml -pl guava-tests

# Run the specific EventBusTest in both guava-tests and android modules
# We need to run tests in both the main pom.xml and android/pom.xml
# Using -Dtest parameter to run only EventBusTest

# First, run the test in the guava-tests module (main pom.xml)
./mvnw -B test -Dtest=EventBusTest -Dmaven.javadoc.skip=true -pl guava-tests
test_status_main=$?

# Then, run the test in the android/guava-tests module
./mvnw -B test -Dtest=EventBusTest -Dmaven.javadoc.skip=true -f android/pom.xml -pl guava-tests
test_status_android=$?

# Both tests must pass
if [ $test_status_main -eq 0 ] && [ $test_status_android -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
