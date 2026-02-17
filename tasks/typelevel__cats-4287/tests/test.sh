#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/IdSuite.scala" "tests/shared/src/test/scala/cats/tests/IdSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/KleisliSuite.scala" "tests/shared/src/test/scala/cats/tests/KleisliSuite.scala"

# Run only the IdSuite and KleisliSuite tests from tests module
sbt "testsJVM / testOnly cats.tests.IdSuite"
if [ $? -ne 0 ]; then
  test_status=1
else
  sbt "testsJVM / testOnly cats.tests.KleisliSuite"
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
