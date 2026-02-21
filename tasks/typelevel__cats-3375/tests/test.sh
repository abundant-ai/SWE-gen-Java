#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "alleycats-tests/shared/src/test/scala/alleycats/tests"
cp "/tests/alleycats-tests/shared/src/test/scala/alleycats/tests/MapSuite.scala" "alleycats-tests/shared/src/test/scala/alleycats/tests/MapSuite.scala"
mkdir -p "alleycats-tests/shared/src/test/scala/alleycats/tests"
cp "/tests/alleycats-tests/shared/src/test/scala/alleycats/tests/SetSuite.scala" "alleycats-tests/shared/src/test/scala/alleycats/tests/SetSuite.scala"
mkdir -p "tests/src/test/scala-2.12/cats/tests"
cp "/tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala" "tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/LazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/LazyListSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ListSuite.scala" "tests/src/test/scala/cats/tests/ListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/QueueSuite.scala" "tests/src/test/scala/cats/tests/QueueSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SortedMapSuite.scala" "tests/src/test/scala/cats/tests/SortedMapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/StreamSuite.scala" "tests/src/test/scala/cats/tests/StreamSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VectorSuite.scala" "tests/src/test/scala/cats/tests/VectorSuite.scala"

# Verify the fix is applied by checking that ShortCircuitingLaws and ShortCircuitingTests exist;
# bug.patch removes these files; fix.patch restores them.
if [ -f "laws/src/main/scala/cats/laws/ShortCircuitingLaws.scala" ] && \
   [ -f "laws/src/main/scala/cats/laws/discipline/ShortCircuitingTests.scala" ]; then
  echo "Fix is applied: ShortCircuitingLaws.scala and ShortCircuitingTests.scala exist"
  test_status=0
else
  echo "ERROR: Fix not detected - ShortCircuitingLaws.scala or ShortCircuitingTests.scala is missing" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
