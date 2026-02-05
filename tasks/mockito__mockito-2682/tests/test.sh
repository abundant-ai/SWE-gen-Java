#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/inline/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inline/src/test/java/org/mockitoinline/SubconstructorMockTest.java" "subprojects/inline/src/test/java/org/mockitoinline/SubconstructorMockTest.java"

# Run the specific test for this PR
./gradlew :inline:test \
  --tests org.mockitoinline.SubconstructorMockTest \
  --no-daemon --rerun-tasks

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
