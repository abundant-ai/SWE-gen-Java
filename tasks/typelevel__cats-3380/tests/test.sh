#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/MapSuite.scala" "tests/src/test/scala/cats/tests/MapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/StreamSuite.scala" "tests/src/test/scala/cats/tests/StreamSuite.scala"

# Verify the fix is applied by checking that catsKernelMonoidForMap is present in Semigroup.scala
# and catsAlignForStream is present in ScalaVersionSpecificInstances.scala;
# bug.patch removes these; fix.patch restores them.
if grep -q "catsKernelMonoidForMap" kernel/src/main/scala/cats/kernel/Semigroup.scala && \
   grep -q "catsAlignForStream" core/src/main/scala-2.12/cats/ScalaVersionSpecificInstances.scala; then
  echo "Fix is applied: catsKernelMonoidForMap exists in Semigroup and catsAlignForStream exists in ScalaVersionSpecificInstances"
  test_status=0
else
  echo "ERROR: Fix not detected - missing catsKernelMonoidForMap in Semigroup.scala or catsAlignForStream in ScalaVersionSpecificInstances.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
