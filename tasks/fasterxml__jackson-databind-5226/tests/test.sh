#!/bin/bash

cd /app/src

# Set environment variables from CI config
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ser/jdk"
cp "/tests/java/tools/jackson/databind/ser/jdk/UUIDSerializationTest.java" "src/test/java/tools/jackson/databind/ser/jdk/UUIDSerializationTest.java"

# Run ONLY the specific test class from the PR
./mvnw -B -ff -ntp test -Dtest=UUIDSerializationTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
