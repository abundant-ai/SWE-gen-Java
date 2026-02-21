#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/EvalSuite.scala" "tests/src/test/scala/cats/tests/EvalSuite.scala"

# Verify the fix is applied by checking that the stack-safety test is present in EvalSuite.scala.
# bug.patch removes the "Defer and FlatMap compose without blowing the stack" test;
# fix.patch restores it.
# Also verify Eval.Leaf is defined in Eval.scala (bug.patch removes it; fix.patch adds it back).

if grep -q "Defer and FlatMap compose without blowing the stack" tests/src/test/scala/cats/tests/EvalSuite.scala && \
   grep -q "sealed abstract class Leaf" core/src/main/scala/cats/Eval.scala; then
  echo "Fix is applied: stack-safety test is present in EvalSuite.scala and Leaf class is present in Eval.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - stack-safety test or Leaf class missing" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
