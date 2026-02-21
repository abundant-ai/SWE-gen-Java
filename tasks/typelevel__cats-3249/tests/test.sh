#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/CatsSuite.scala" "tests/src/test/scala/cats/tests/CatsSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/EitherSuite.scala" "tests/src/test/scala/cats/tests/EitherSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ListSuite.scala" "tests/src/test/scala/cats/tests/ListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ParallelSuite.scala" "tests/src/test/scala/cats/tests/ParallelSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/StreamSuite.scala" "tests/src/test/scala/cats/tests/StreamSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SyntaxSuite.scala" "tests/src/test/scala/cats/tests/SyntaxSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VectorSuite.scala" "tests/src/test/scala/cats/tests/VectorSuite.scala"

# Run only the specific test suites for this PR using Scala 2.11.12
# Incremental compilation detects source changes from the agent's patch
sbt "testsJVM/testOnly cats.tests.CatsSuite cats.tests.EitherSuite cats.tests.ListSuite cats.tests.ParallelSuite cats.tests.StreamSuite cats.tests.SyntaxSuite cats.tests.VectorSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
