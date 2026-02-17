#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/SyntaxSerializationSuite.scala" "tests/shared/src/test/scala/cats/tests/SyntaxSerializationSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala" "tests/shared/src/test/scala/cats/tests/SyntaxSuite.scala"

# Compile test sources (SBT will incrementally compile only what changed)
# This will fail in BASE state because test files use code that doesn't exist
# This will succeed in HEAD state because fix.patch restores the missing functionality
sbt "testsJVM / Test / compile"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
