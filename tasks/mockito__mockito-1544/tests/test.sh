#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/inline/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inline/src/test/java/org/mockitoinline/OneLinerStubStressTest.java" "subprojects/inline/src/test/java/org/mockitoinline/OneLinerStubStressTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :inline:cleanTest --no-daemon

# Run the specific test file for this PR
./gradlew :inline:test --tests org.mockitoinline.OneLinerStubStressTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
