#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala-2.13+/cats/tests"
cp "/tests/shared/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/shared/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptySeqSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/shared/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"

# Compile test sources (SBT will incrementally compile only what changed)
# This will fail in BASE state because test files use distinctBy which doesn't exist
# This will succeed in HEAD state because fix.patch restores the distinctBy method
sbt "testsJVM / Test / compile"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
