#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.12/cats/tests"
cp "/tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala" "tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/FoldableSuite.scala" "tests/src/test/scala/cats/tests/FoldableSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ReducibleSuite.scala" "tests/src/test/scala/cats/tests/ReducibleSuite.scala"

# Run only the specific test suites for this PR
# Incremental compilation detects source changes from the agent's patch
sbt "testsJVM/testOnly cats.tests.NonEmptyStreamSuite cats.tests.NonEmptyLazyListSuite cats.tests.FoldableSuite cats.tests.NonEmptyChainSuite cats.tests.NonEmptyListSuite cats.tests.NonEmptyVectorSuite cats.tests.ReducibleSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
