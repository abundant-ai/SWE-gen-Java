#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/java-test/src/test/java/retrofit2"
cp "/tests/retrofit/java-test/src/test/java/retrofit2/RequestFactoryTest.java" "retrofit/java-test/src/test/java/retrofit2/RequestFactoryTest.java"

# Clean and recompile test classes after copying
./gradlew :retrofit:java-test:clean :retrofit:java-test:testClasses --no-daemon

# Run only the specific test from the PR (in java-test submodule)
# Note: The default 'test' task is disabled, so we use testJdk21 instead
./gradlew :retrofit:java-test:testJdk21 --tests retrofit2.RequestFactoryTest.tagPrimitive --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
