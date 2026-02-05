#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/CallTest.java" "retrofit/src/test/java/retrofit2/CallTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/DefaultCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit2/DefaultCallAdapterFactoryTest.java"

# Run specific tests for this PR
mvn test -Dtest=CallTest,DefaultCallAdapterFactoryTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
