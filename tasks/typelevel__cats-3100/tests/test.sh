#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala" "tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ListSuite.scala" "tests/src/test/scala/cats/tests/ListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/QueueSuite.scala" "tests/src/test/scala/cats/tests/QueueSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VectorSuite.scala" "tests/src/test/scala/cats/tests/VectorSuite.scala"

# Run only the specific test suites for this PR
# Incremental compilation detects source changes from the agent's patch
sbt "testsJVM/testOnly cats.tests.TraverseLazyListSuite cats.tests.TraverseLazyListSuiteUnderlying cats.tests.ListSuite cats.tests.QueueSuite cats.tests.VectorSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
