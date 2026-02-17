#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/KleisliSuite.scala" "tests/src/test/scala/cats/tests/KleisliSuite.scala"
cp "/tests/src/test/scala/cats/tests/TraverseSuite.scala" "tests/src/test/scala/cats/tests/TraverseSuite.scala"

# Run only the specific test classes for this PR
sbt "testsJVM / testOnly cats.tests.KleisliSuite cats.tests.TraverseSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
