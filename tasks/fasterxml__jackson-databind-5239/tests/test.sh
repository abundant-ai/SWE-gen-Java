#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test-jdk17/java/com/fasterxml/jackson/databind/records"
cp "/tests/src/test-jdk17/java/com/fasterxml/jackson/databind/records/JsonIdentityOnRecord5238Test.java" "src/test-jdk17/java/com/fasterxml/jackson/databind/records/JsonIdentityOnRecord5238Test.java"

# Recompile test sources to pick up the copied test file
./mvnw -B -ntp test-compile

# Run the specific test class
./mvnw -B -ntp test -Dtest=JsonIdentityOnRecord5238Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
