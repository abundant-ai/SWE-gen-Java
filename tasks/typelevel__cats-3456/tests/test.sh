#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/KleisliSuite.scala" "tests/src/test/scala/cats/tests/KleisliSuite.scala"

# Verify the fix is applied by checking that the overridden methods exist in Kleisli.scala.
# bug.patch removes combineKEval and map2Eval from Kleisli;
# fix.patch restores both of them.
if grep -q "def combineKEval" core/src/main/scala/cats/data/Kleisli.scala && \
   grep -q "def map2Eval" core/src/main/scala/cats/data/Kleisli.scala; then
  echo "Fix is applied: combineKEval and map2Eval exist in Kleisli.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - missing one or more of: combineKEval, map2Eval in Kleisli.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
