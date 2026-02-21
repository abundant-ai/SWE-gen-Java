#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"

# Verify that groupMap, groupMapReduce, groupMapReduceWith methods are defined in Chain.scala.
# bug.patch removes these methods; fix.patch restores them.
# The HEAD test files (ChainSuite, NonEmptyChainSuite, NonEmptyListSuite) reference these methods.

if grep -q "def groupMap\b" core/src/main/scala/cats/data/Chain.scala && \
   grep -q "def groupMapReduce\b" core/src/main/scala/cats/data/Chain.scala && \
   grep -q "def groupMapReduceWith\b" core/src/main/scala/cats/data/Chain.scala && \
   grep -q "def groupMapNem\b" core/src/main/scala/cats/data/NonEmptyChain.scala && \
   grep -q "def groupMapNem\b" core/src/main/scala/cats/data/NonEmptyList.scala; then
  echo "groupMap, groupMapReduce, groupMapReduceWith methods found - fix is applied"
  test_status=0
else
  echo "ERROR: groupMap or related methods not found in Chain.scala" >&2
  echo "These methods are missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
