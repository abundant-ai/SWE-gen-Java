#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state test files)
mkdir -p "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2"
cp "/tests/retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java" "retrofit-adapters/rxjava2/src/test/java/retrofit2/adapter/rxjava2/AsyncTest.java"

# Run specific test for this PR - AsyncTest
# Clean and rebuild both retrofit (core) and adapter modules to ensure all changes are picked up
mvn clean install -DskipTests -Dmaven.javadoc.skip=true -pl retrofit,retrofit-adapters/rxjava2 -am && \
mvn test -Dtest=AsyncTest -pl retrofit-adapters/rxjava2
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
