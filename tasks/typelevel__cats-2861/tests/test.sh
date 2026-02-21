#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/MapSuite.scala" "tests/src/test/scala/cats/tests/MapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/RegressionSuite.scala" "tests/src/test/scala/cats/tests/RegressionSuite.scala"

# Run only the specific test suites for this PR
sbt "testsJVM/testOnly cats.tests.MapSuite cats.tests.RegressionSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
