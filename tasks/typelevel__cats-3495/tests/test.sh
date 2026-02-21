#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VarianceSuite.scala" "tests/src/test/scala/cats/tests/VarianceSuite.scala"

# Verify the fix is applied by checking that leftNarrow/rightWiden and autoConvertProfunctorVariance
# are present in the core source files (which are not overwritten by test.sh).
# bug.patch removes leftNarrow/rightWiden from Profunctor.scala and autoConvertProfunctorVariance
# from VarianceConversions.scala; fix.patch restores them.
if grep -q "leftNarrow" core/src/main/scala/cats/arrow/Profunctor.scala && \
   grep -q "rightWiden" core/src/main/scala/cats/arrow/Profunctor.scala && \
   grep -q "autoConvertProfunctorVariance" core/src/main/scala/cats/conversions/VarianceConversions.scala; then
  echo "Fix is applied: leftNarrow/rightWiden and autoConvertProfunctorVariance are present"
  test_status=0
else
  echo "ERROR: Fix not detected - leftNarrow/rightWiden missing from Profunctor.scala or autoConvertProfunctorVariance missing from VarianceConversions.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
