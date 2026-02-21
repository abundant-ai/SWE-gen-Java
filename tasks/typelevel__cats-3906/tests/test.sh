#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "free/src/test/scala/cats/free"
cp "/tests/free/src/test/scala/cats/free/FreeApplicativeSuite.scala" "free/src/test/scala/cats/free/FreeApplicativeSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala" "tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IdSuite.scala" "tests/src/test/scala/cats/tests/IdSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/MonadSuite.scala" "tests/src/test/scala/cats/tests/MonadSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/UnorderedTraverseSuite.scala" "tests/src/test/scala/cats/tests/UnorderedTraverseSuite.scala"

# Run only the specific test classes for this PR using Scala 3 (bug is Scala 3 specific)
sbt "++ 3.0.0" "freeJVM / testOnly cats.free.FreeApplicativeSuite" "testsJVM / testOnly cats.tests.IdSuite cats.tests.MonadSuite cats.tests.UnorderedTraverseSuite cats.tests.TraverseLazyListSuite cats.tests.TraverseLazyListSuiteUnderlying cats.tests.TraverseFilterLazyListSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
