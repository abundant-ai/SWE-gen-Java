#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "free/src/test/scala/cats/free"
cp "/tests/free/src/test/scala/cats/free/FreeTSuite.scala" "free/src/test/scala/cats/free/FreeTSuite.scala"

# Run only the specific test suites for this PR
# Incremental compilation detects source changes from the agent's patch
sbt "freeJVM/testOnly cats.free.FreeTSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
