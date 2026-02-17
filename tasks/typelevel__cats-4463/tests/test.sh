#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/shared/src/test/scala/cats/tests"
cp "/tests/shared/src/test/scala/cats/tests/MapSuite.scala" "tests/shared/src/test/scala/cats/tests/MapSuite.scala"

# Compile first to avoid timeout during test execution
sbt "testsJVM / Test / compile" >/dev/null 2>&1

# Run only the MapSuite tests
# In BASE state: The stack overflow tests will fail because the buggy implementation causes stack overflow
# In HEAD state: All tests pass because the fixed implementation prevents stack overflow
sbt "testsJVM / testOnly cats.tests.MapSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
