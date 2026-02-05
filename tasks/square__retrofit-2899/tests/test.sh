#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-mock/src/test/java/retrofit2/mock"
cp "/tests/retrofit-mock/src/test/java/retrofit2/mock/CallsTest.java" "retrofit-mock/src/test/java/retrofit2/mock/CallsTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/InvocationTest.java" "retrofit/src/test/java/retrofit2/InvocationTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -DskipTests -Dmaven.javadoc.skip=true && \
mvn test -Dtest=CallsTest -pl retrofit-mock && \
mvn test -Dtest=InvocationTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
