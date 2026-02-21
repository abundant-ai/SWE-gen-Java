#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/BifoldableSuite.scala" "tests/src/test/scala/cats/tests/BifoldableSuite.scala"

# Run only the specific test suites for this PR using Scala 2.11.12
# Incremental compilation detects source changes from the agent's patch
sbt "testsJVM/testOnly cats.tests.BifoldableSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
