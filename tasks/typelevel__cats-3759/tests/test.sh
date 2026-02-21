#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kernel-laws/shared/src/test/scala/cats/kernel/laws"
cp "/tests/kernel-laws/shared/src/test/scala/cats/kernel/laws/LawTests.scala" "kernel-laws/shared/src/test/scala/cats/kernel/laws/LawTests.scala"

# Run only the Byte-related BoundedEnumerable/LowerBounded/UpperBounded tests added in this PR
sbt "kernelLawsJVM / testOnly cats.kernel.laws.Tests -- '*Byte*'"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
