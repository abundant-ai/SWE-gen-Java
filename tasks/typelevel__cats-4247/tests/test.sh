#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
# This test file includes tests for the new Long index methods added in the fix
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/TraverseSuite.scala" "tests/shared/src/test/scala/cats/tests/TraverseSuite.scala"

# Run only the specific test classes for this PR (running just one suite to reduce compilation time)
sbt "testsJVM / testOnly cats.tests.TraverseListSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
