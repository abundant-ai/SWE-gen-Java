#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala" "tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala"

# Run only the specific test class for this PR
sbt "testsJVM / testOnly cats.tests.SyntaxSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
