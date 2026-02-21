#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ReducibleSuite.scala" "tests/src/test/scala/cats/tests/ReducibleSuite.scala"

# Verify the fix is applied by checking that the Source-based implementation is present
# in the core source files (which are not overwritten by test.sh).
# bug.patch removes Source-based reduceRightToOption/reduceRightTo implementations;
# fix.patch restores them.
if grep -q "Source.fromFoldable" core/src/main/scala/cats/Foldable.scala && \
   grep -q "Foldable.Source" core/src/main/scala/cats/Reducible.scala; then
  echo "Fix is applied: Source-based implementations are present in Foldable.scala and Reducible.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - Source-based implementation missing from Foldable.scala or Reducible.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
