#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/EitherTSuite.scala" "tests/src/test/scala/cats/tests/EitherTSuite.scala"
cp "/tests/src/test/scala/cats/tests/ValidatedSuite.scala" "tests/src/test/scala/cats/tests/ValidatedSuite.scala"
# Restore these files to HEAD state since fix.patch modifies their dependencies (Chain.==: and NonEmptyMap Hash)
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
cp "/tests/src/test/scala/cats/tests/NonEmptyMapSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyMapSuite.scala"

# Run only the specific test suites for this PR
sbt "testsJVM/testOnly cats.tests.EitherTSuite cats.tests.ValidatedSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
