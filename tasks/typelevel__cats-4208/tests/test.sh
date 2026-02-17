#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/ApplicativeSuite.scala" "tests/shared/src/test/scala/cats/tests/ApplicativeSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/MonadSuite.scala" "tests/shared/src/test/scala/cats/tests/MonadSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/ParallelSuite.scala" "tests/shared/src/test/scala/cats/tests/ParallelSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala" "tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala"

# Run only the specific test classes for this PR
# SyntaxSuite is a compile-time check object, not a runtime test, so we only run the 3 actual test suites
sbt "testsJVM / testOnly cats.tests.ApplicativeSuite cats.tests.MonadSuite cats.tests.ParallelSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
