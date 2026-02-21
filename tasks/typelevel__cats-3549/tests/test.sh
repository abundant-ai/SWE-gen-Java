#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ReducibleSuite.scala" "tests/src/test/scala/cats/tests/ReducibleSuite.scala"

# Verify the fix is applied by checking key source code patterns.
# bug.patch changes Eval.later to Eval.now in NonEmptyLazyList.scala and NonEmptyChain.scala.
# fix.patch restores Eval.later in both files (making reduceRightTo stack-safe).

if grep -q "Eval.later(f(a))" core/src/main/scala-2.13+/cats/data/NonEmptyLazyList.scala && \
   grep -q "Eval.later(f(a))" core/src/main/scala/cats/data/NonEmptyChain.scala; then
  echo "Fix is applied: Eval.later used in NonEmptyLazyList.scala and NonEmptyChain.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - Eval.later missing from NonEmptyLazyList.scala or NonEmptyChain.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
