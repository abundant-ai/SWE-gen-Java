#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "testkit/src/main/scala/cats/tests"
cp "/tests/testkit/src/main/scala/cats/tests/CatsSuite.scala" "testkit/src/main/scala/cats/tests/CatsSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/tests/src/test/scala/cats/tests/SortedSetSuite.scala" "tests/src/test/scala/cats/tests/SortedSetSuite.scala"

# Run only the specific test suites for this PR
sbt "testsJVM/testOnly cats.tests.SortedSetSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
