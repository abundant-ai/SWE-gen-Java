#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/BifunctorSuite.scala" "tests/shared/src/test/scala/cats/tests/BifunctorSuite.scala"

# Compile first to avoid timeout during test execution
sbt "testsJVM / Test / compile" >/dev/null 2>&1

# Run only the BifunctorSuite tests
sbt "testsJVM / testOnly cats.tests.BifunctorSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
