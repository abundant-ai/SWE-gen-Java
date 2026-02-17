#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala-2.13+/cats/tests"
cp "/tests/shared/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/shared/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"

# Run only the specific test classes for this PR
sbt "testsJVM / testOnly cats.tests.NonEmptyLazyListSuite cats.tests.ReducibleNonEmptyLazyListSuite cats.tests.NonEmptyChainSuite cats.tests.ReducibleNonEmptyChainSuite cats.tests.NonEmptyListSuite cats.tests.DeprecatedNonEmptyListSuite cats.tests.ReducibleNonEmptyListSuite cats.tests.NonEmptySeqSuite cats.tests.NonEmptyVectorSuite cats.tests.ReducibleNonEmptyVectorSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
