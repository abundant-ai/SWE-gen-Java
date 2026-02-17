#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/SeqSuite.scala" "tests/shared/src/test/scala/cats/tests/SeqSuite.scala"

# Run only the specific test classes for this PR
sbt "testsJVM / testOnly cats.tests.NonEmptyListSuite cats.tests.NonEmptySeqSuite cats.tests.NonEmptyVectorSuite cats.tests.SeqSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
