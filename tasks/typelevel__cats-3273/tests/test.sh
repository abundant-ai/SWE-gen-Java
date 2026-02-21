#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/ArraySeqSuite.scala" "tests/src/test/scala-2.13+/cats/tests/ArraySeqSuite.scala"

# Run only the specific test suite for this PR using Scala 2.13.1
# (ArraySeqSuite.scala is in scala-2.13+ directory, only included in Scala 2.13 builds)
# Clean kernel, core, and tests to force recompilation and detect deleted sources from bug.patch
sbt "++2.13.1 kernelJVM/clean" "++2.13.1 coreJVM/clean" "++2.13.1 testsJVM/clean" "++2.13.1 testsJVM/testOnly cats.tests.ArraySeqSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
