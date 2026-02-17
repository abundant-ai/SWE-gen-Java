#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "free/src/test/scala-2.13+/cats/free"
cp "/tests/free/src/test/scala-2.13+/cats/free/FreeStructuralSuite.scala" "free/src/test/scala-2.13+/cats/free/FreeStructuralSuite.scala"

# Run only the specific test classes for this PR.
# The build.sbt was modified in Docker build to add -Xsource:3 for the free project
# (needed for by-name implicits in FreeStructuralInstances).
sbt "freeJVM / testOnly cats.free.FreeStructuralSuite"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
