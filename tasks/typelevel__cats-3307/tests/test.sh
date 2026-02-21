#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyCollectionSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyCollectionSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"

# Run only the specific test suites for this PR
sbt "testsJVM / testOnly cats.tests.NonEmptyLazyListSuite cats.tests.ChainSuite cats.tests.NonEmptyChainSuite cats.tests.NonEmptyCollectionSuite cats.tests.NonEmptyListSuite cats.tests.NonEmptyVectorSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
