#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/EitherTSuite.scala" "tests/src/test/scala/cats/tests/EitherTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IorTSuite.scala" "tests/src/test/scala/cats/tests/IorTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/OptionTSuite.scala" "tests/src/test/scala/cats/tests/OptionTSuite.scala"

# Verify the fix is applied by checking that the new methods exist in the source files.
# bug.patch removes fromOptionM from EitherT/IorT and toRightF/toLeftF from OptionT;
# fix.patch restores all of them.
if grep -q "def fromOptionM" core/src/main/scala/cats/data/EitherT.scala && \
   grep -q "def fromOptionM" core/src/main/scala/cats/data/IorT.scala && \
   grep -q "def toRightF" core/src/main/scala/cats/data/OptionT.scala && \
   grep -q "def toLeftF" core/src/main/scala/cats/data/OptionT.scala; then
  echo "Fix is applied: fromOptionM exists in EitherT/IorT and toRightF/toLeftF exist in OptionT"
  test_status=0
else
  echo "ERROR: Fix not detected - missing one or more of: fromOptionM in EitherT.scala/IorT.scala, toRightF/toLeftF in OptionT.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
