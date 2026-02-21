#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.x/cats/tests"
cp "/tests/src/test/scala-2.x/cats/tests/FunctionKSuite.scala" "tests/src/test/scala-2.x/cats/tests/FunctionKSuite.scala"

# Verify the fix is applied by checking that liftFunction method exists in source files
# and the scala-2.x test file references it.
# bug.patch removes liftFunction from FunctionKMacros.scala and removes the scala-2.x test file;
# fix.patch restores all of them.
if grep -q "def liftFunction" core/src/main/scala-2.x/src/main/scala/cats/arrow/FunctionKMacros.scala && \
   grep -q "liftFunction" tests/src/test/scala-2.x/cats/tests/FunctionKSuite.scala; then
  echo "Fix is applied: liftFunction exists in source and test files"
  test_status=0
else
  echo "ERROR: Fix not detected - missing liftFunction in source or test files" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
