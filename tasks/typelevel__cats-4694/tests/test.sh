#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/ChainSuite.scala" "tests/shared/src/test/scala/cats/tests/ChainSuite.scala"

# Run specific test suite (SBT will incrementally compile only what changed)
sbt "testsJVM/testOnly cats.tests.ChainSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
