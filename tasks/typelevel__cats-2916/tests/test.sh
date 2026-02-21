#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
# The bug.patch reverts several test files to use the old scalaVersionSpecific import.
# We must restore the HEAD versions of all affected files so the module compiles correctly
# after the oracle's fix.patch removes scalaVersionSpecific.scala.
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/WriterTSuite.scala" "tests/src/test/scala/cats/tests/WriterTSuite.scala"
cp "/tests/src/test/scala/cats/tests/BinCodecInvariantMonoidalSuite.scala" "tests/src/test/scala/cats/tests/BinCodecInvariantMonoidalSuite.scala"
cp "/tests/src/test/scala/cats/tests/FoldableSuite.scala" "tests/src/test/scala/cats/tests/FoldableSuite.scala"
cp "/tests/src/test/scala/cats/tests/LazyListSuite.scala" "tests/src/test/scala/cats/tests/LazyListSuite.scala"
cp "/tests/src/test/scala/cats/tests/OneAndSuite.scala" "tests/src/test/scala/cats/tests/OneAndSuite.scala"
cp "/tests/src/test/scala/cats/tests/ParallelSuite.scala" "tests/src/test/scala/cats/tests/ParallelSuite.scala"
cp "/tests/src/test/scala/cats/tests/RegressionSuite.scala" "tests/src/test/scala/cats/tests/RegressionSuite.scala"
cp "/tests/src/test/scala/cats/tests/TraverseSuite.scala" "tests/src/test/scala/cats/tests/TraverseSuite.scala"

# Run only the specific test suite for this PR
sbt "testsJVM/testOnly cats.tests.WriterTSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
