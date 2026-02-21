#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VarianceSuite.scala" "tests/src/test/scala/cats/tests/VarianceSuite.scala"

# Verify the fix is applied by checking that the conversions package and VarianceSuite exist.
# bug.patch removes VarianceSuite.scala and the cats.conversions package (VarianceConversions.scala, all.scala, package.scala);
# fix.patch restores all of them.
if test -f tests/src/test/scala/cats/tests/VarianceSuite.scala && \
   test -f core/src/main/scala/cats/conversions/VarianceConversions.scala && \
   test -f core/src/main/scala/cats/conversions/all.scala && \
   grep -q "cats.conversions.all" tests/src/test/scala/cats/tests/VarianceSuite.scala; then
  echo "Fix is applied: VarianceSuite.scala and cats.conversions package exist"
  test_status=0
else
  echo "ERROR: Fix not detected - missing VarianceSuite.scala or cats.conversions package files" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
