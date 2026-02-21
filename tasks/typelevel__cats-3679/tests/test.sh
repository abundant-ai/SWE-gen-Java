#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyCollectionSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyCollectionSuite.scala"

# Verify that the grouped method is defined in NonEmptyCollection.scala and its implementations.
# bug.patch removes grouped from NonEmptyCollection trait and all NonEmpty* implementations.
# fix.patch restores them. The HEAD test file (NonEmptyCollectionSuite) references grouped.

if grep -q "def grouped\b" core/src/main/scala/cats/data/NonEmptyCollection.scala && \
   grep -q "def grouped\b" core/src/main/scala/cats/data/NonEmptyList.scala && \
   grep -q "def grouped\b" core/src/main/scala/cats/data/NonEmptyVector.scala && \
   grep -q "def grouped\b" core/src/main/scala/cats/data/NonEmptyChain.scala && \
   grep -q "def grouped\b" core/src/main/scala/cats/data/NonEmptySeq.scala && \
   grep -q "def grouped\b" "core/src/main/scala-2.13+/cats/data/NonEmptyLazyList.scala"; then
  echo "grouped method found in NonEmptyCollection and all implementations - fix is applied"
  test_status=0
else
  echo "ERROR: grouped method not found in NonEmptyCollection or one of its implementations" >&2
  echo "These methods are missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
