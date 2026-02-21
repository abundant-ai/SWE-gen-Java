#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/FoldableSuite.scala" "tests/src/test/scala/cats/tests/FoldableSuite.scala"

# Verify that FoldableNFunctions is extended by Foldable in Foldable.scala.
# bug.patch removes FoldableNFunctions from Foldable; fix.patch restores it.
# FoldableNFunctions provides sliding2 through sliding22 methods on Foldable.

if grep -q "FoldableNFunctions" core/src/main/scala/cats/Foldable.scala && \
   grep -q "GenFoldableArityFunctions" project/Boilerplate.scala; then
  echo "FoldableNFunctions found in Foldable.scala and GenFoldableArityFunctions found in Boilerplate.scala - sliding arity functions are present"
  test_status=0
else
  echo "ERROR: FoldableNFunctions not found in Foldable.scala or GenFoldableArityFunctions not found in Boilerplate.scala" >&2
  echo "Sliding arity functions are missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
