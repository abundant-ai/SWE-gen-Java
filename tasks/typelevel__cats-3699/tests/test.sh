#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/FoldableSuite.scala" "tests/src/test/scala/cats/tests/FoldableSuite.scala"

# Verify that minimumList/maximumList are defined in Foldable.scala and
# minimumNel/maximumNel are defined in Reducible.scala.
# bug.patch removes these methods; fix.patch restores them.

if grep -q "def minimumList" core/src/main/scala/cats/Foldable.scala && \
   grep -q "def maximumList" core/src/main/scala/cats/Foldable.scala && \
   grep -q "def minimumNel" core/src/main/scala/cats/Reducible.scala && \
   grep -q "def maximumNel" core/src/main/scala/cats/Reducible.scala; then
  echo "minimumList/maximumList found in Foldable.scala and minimumNel/maximumNel found in Reducible.scala - methods are present"
  test_status=0
else
  echo "ERROR: minimumList/maximumList not found in Foldable.scala or minimumNel/maximumNel not found in Reducible.scala" >&2
  echo "These methods are missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
