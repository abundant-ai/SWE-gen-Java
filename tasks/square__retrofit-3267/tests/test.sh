#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-mock/src/test/java/retrofit2/mock"
cp "/tests/retrofit-mock/src/test/java/retrofit2/mock/BehaviorDelegateKotlinTest.kt" "retrofit-mock/src/test/java/retrofit2/mock/BehaviorDelegateKotlinTest.kt"

# Run specific tests for this PR
mvn test -Dtest=BehaviorDelegateKotlinTest -pl retrofit-mock
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
