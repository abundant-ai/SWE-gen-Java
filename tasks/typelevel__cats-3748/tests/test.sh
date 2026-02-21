#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ContTSuite.scala" "tests/src/test/scala/cats/tests/ContTSuite.scala"

# Verify that resetT and shiftT delimited continuation operators exist in ContT.scala.
# bug.patch removes these operators; fix.patch restores them.
# These methods are essential for delimited continuation support in ContT.

if grep -q "def resetT" core/src/main/scala/cats/data/ContT.scala && \
   grep -q "def shiftT" core/src/main/scala/cats/data/ContT.scala; then
  echo "resetT and shiftT found in ContT.scala - delimited continuation support is present"
  test_status=0
else
  echo "ERROR: resetT or shiftT not found in ContT.scala" >&2
  echo "Delimited continuation support is missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
