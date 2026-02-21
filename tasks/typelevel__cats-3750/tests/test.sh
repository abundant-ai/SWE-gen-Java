#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "alleycats-tests/native/src/test/scala/alleycats/tests"
cp "/tests/alleycats-tests/native/src/test/scala/alleycats/tests/TestSettings.scala" "alleycats-tests/native/src/test/scala/alleycats/tests/TestSettings.scala"
mkdir -p "native/src/test/scala/cats/native/tests"
cp "/tests/native/src/test/scala/cats/native/tests/FutureSuite.scala" "native/src/test/scala/cats/native/tests/FutureSuite.scala"

# Verify that the Scala Native platform file exists.
# bug.patch deletes kernel-laws/native/src/main/scala/cats/platform/Platform.scala as part of
# removing Scala Native cross-compilation support. fix.patch recreates it as part of restoring
# Scala Native support. This file is essential for cross-compiling cats for Scala Native.
if [ -f "kernel-laws/native/src/main/scala/cats/platform/Platform.scala" ]; then
  echo "Native Platform.scala found - Scala Native support is present"
  test_status=0
else
  echo "ERROR: kernel-laws/native/src/main/scala/cats/platform/Platform.scala not found" >&2
  echo "Scala Native support is missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
