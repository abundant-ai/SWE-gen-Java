#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/AsSuite.scala" "tests/src/test/scala/cats/tests/AsSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IsSuite.scala" "tests/src/test/scala/cats/tests/IsSuite.scala"

# Verify the fix is applied by checking that toPredef method and IsSupport/AsSupport traits are present.
# bug.patch removes toPredef from As.scala and Is.scala, removes AsSupport/IsSupport traits,
# and removes tests that use toPredef; fix.patch restores all of these.
if grep -q "toPredef" tests/src/test/scala/cats/tests/AsSuite.scala && \
   grep -q "toPredef" tests/src/test/scala/cats/tests/IsSuite.scala && \
   grep -q "toPredef" core/src/main/scala/cats/evidence/As.scala && \
   grep -q "toPredef" core/src/main/scala/cats/evidence/Is.scala; then
  echo "Fix is applied: toPredef methods and tests are present in As.scala, Is.scala, AsSuite.scala, and IsSuite.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - toPredef method or test usage missing" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
