#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.12/cats/tests"
cp "/tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala" "tests/src/test/scala-2.12/cats/tests/NonEmptyStreamSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyMapSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyMapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyVectorSuite.scala"

# Verify the fix is applied by checking that nonEmptyTraverse is present in the laws and discipline files
# bug.patch removes nonEmptyTraverse from ShortCircuitingLaws.scala and ShortCircuitingTests.scala;
# fix.patch restores them.
if grep -q "nonEmptyTraverseShortCircuits" laws/src/main/scala/cats/laws/ShortCircuitingLaws.scala && \
   grep -q "def nonEmptyTraverse" laws/src/main/scala/cats/laws/discipline/ShortCircuitingTests.scala; then
  echo "Fix is applied: nonEmptyTraverse exists in ShortCircuitingLaws and ShortCircuitingTests"
  test_status=0
else
  echo "ERROR: Fix not detected - missing nonEmptyTraverse in laws or discipline files" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
