#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SyntaxSuite.scala" "tests/src/test/scala/cats/tests/SyntaxSuite.scala"

# SyntaxSuite is a compilation-only test - verify syntax by compiling the test sources
sbt "testsJVM / Test / compile"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
