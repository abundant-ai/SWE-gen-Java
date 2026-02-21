#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SemigroupSuite.scala" "tests/src/test/scala/cats/tests/SemigroupSuite.scala"

# Verify the fix is applied by checking that FunctionK.scala extends FunctionKMacroMethods
# and that the separate FunctionKMacros.scala file exists.
# bug.patch inlines the macro implementation into FunctionK.scala and removes the separate files;
# fix.patch restores FunctionK.scala to extend FunctionKMacroMethods and recreates the separate files.
if grep -q "FunctionKMacroMethods" core/src/main/scala/cats/arrow/FunctionK.scala && \
   test -f core/src/main/scala-2.x/src/main/scala/cats/arrow/FunctionKMacros.scala; then
  echo "Fix is applied: FunctionK.scala extends FunctionKMacroMethods and FunctionKMacros.scala exists"
  test_status=0
else
  echo "ERROR: Fix not detected - FunctionKMacroMethods missing from FunctionK.scala or FunctionKMacros.scala does not exist" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
