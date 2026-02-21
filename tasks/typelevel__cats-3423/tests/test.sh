#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala" "tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/NonEmptyListSuite.scala" "tests/src/test/scala/cats/tests/NonEmptyListSuite.scala"

# Verify the fix is applied by checking that the toNev methods exist in source files
# and the test files reference them.
# bug.patch removes toNev from NonEmptyLazyList and NonEmptyList;
# fix.patch restores all of them.
if grep -q "def toNev" core/src/main/scala-2.13+/cats/data/NonEmptyLazyList.scala && \
   grep -q "def toNev" core/src/main/scala/cats/data/NonEmptyList.scala && \
   grep -q "toNev" tests/src/test/scala-2.13+/cats/tests/NonEmptyLazyListSuite.scala && \
   grep -q "toNev" tests/src/test/scala/cats/tests/NonEmptyListSuite.scala; then
  echo "Fix is applied: toNev methods exist in source and test files"
  test_status=0
else
  echo "ERROR: Fix not detected - missing toNev methods in source or test files" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
