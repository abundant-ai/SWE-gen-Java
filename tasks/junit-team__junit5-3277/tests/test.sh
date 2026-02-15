#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform"
cp "/tests/platform-tests/src/test/java/org/junit/platform/StackTracePruningTests.java" "platform-tests/src/test/java/org/junit/platform/StackTracePruningTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/util"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/util/ClassNamePatternFilterUtilsTests.java" "platform-tests/src/test/java/org/junit/platform/commons/util/ClassNamePatternFilterUtilsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/util"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/util/ExceptionUtilsTests.java" "platform-tests/src/test/java/org/junit/platform/commons/util/ExceptionUtilsTests.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tests:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :platform-tests:test --tests org.junit.platform.StackTracePruningTests \
    --tests org.junit.platform.commons.util.ClassNamePatternFilterUtilsTests \
    --tests org.junit.platform.commons.util.ExceptionUtilsTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
