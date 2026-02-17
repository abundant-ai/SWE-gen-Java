#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "free/src/test/scala-2.13+/cats/free"
cp "/tests/free/src/test/scala-2.13+/cats/free/FreeStructuralSuite.scala" "free/src/test/scala-2.13+/cats/free/FreeStructuralSuite.scala"
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/FunctionSuite.scala" "tests/shared/src/test/scala/cats/tests/FunctionSuite.scala"

# Run only the FreeStructuralSuite test from free module and FunctionSuite from tests module
sbt "freeJVM / testOnly cats.free.FreeStructuralSuite"
if [ $? -ne 0 ]; then
  test_status=1
else
  sbt "testsJVM / testOnly cats.tests.FunctionSuite"
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
