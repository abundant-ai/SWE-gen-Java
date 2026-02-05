#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/IMethods.java" "src/test/java/org/mockitousage/IMethods.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/MethodsImpl.java" "src/test/java/org/mockitousage/MethodsImpl.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithAdditionalAnswersTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithAdditionalAnswersTest.java"

# Run the specific test files for this PR
./gradlew :test --tests org.mockitousage.stubbing.StubbingWithAdditionalAnswersTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
