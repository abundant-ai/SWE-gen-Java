#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/stubbing/answers"
cp "/tests/java/org/mockito/internal/stubbing/answers/ThrowsExceptionTest.java" "src/test/java/org/mockito/internal/stubbing/answers/ThrowsExceptionTest.java"
mkdir -p "src/test/java/org/mockitousage/bugs"
cp "/tests/java/org/mockitousage/bugs/FillInStackTraceScenariosTest.java" "src/test/java/org/mockitousage/bugs/FillInStackTraceScenariosTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingConsecutiveAnswersTest.java" "src/test/java/org/mockitousage/stubbing/StubbingConsecutiveAnswersTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test files for this PR (in the root project)
./gradlew :test \
  --tests org.mockito.internal.stubbing.answers.ThrowsExceptionTest \
  --tests org.mockitousage.bugs.FillInStackTraceScenariosTest \
  --tests org.mockitousage.stubbing.StubbingConsecutiveAnswersTest \
  --tests org.mockitousage.stubbing.StubbingWithThrowablesTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
