#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "js/src/test/scala/cats/tests"
cp "/tests/js/src/test/scala/cats/tests/FutureTests.scala" "js/src/test/scala/cats/tests/FutureTests.scala"
mkdir -p "jvm/src/test/scala/cats/tests"
cp "/tests/jvm/src/test/scala/cats/tests/FutureSuite.scala" "jvm/src/test/scala/cats/tests/FutureSuite.scala"

# Verify the fix is applied by checking key source code patterns.
# bug.patch removes Future instances from Invariant.scala, Semigroupal.scala, and Semigroup.scala.
# fix.patch restores catsInstancesForFuture in Invariant.scala and related Future instances.

if grep -q "catsInstancesForFuture" core/src/main/scala/cats/Invariant.scala && \
   grep -q "catsKernelSemigroupForFuture" kernel/src/main/scala/cats/kernel/Semigroup.scala; then
  echo "Fix is applied: Future instances present in Invariant.scala and Semigroup.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - Future instances missing from Invariant.scala or Semigroup.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
