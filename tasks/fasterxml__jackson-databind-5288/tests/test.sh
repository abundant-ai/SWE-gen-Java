#!/bin/bash

cd /app/src

# Set environment variables for testing
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/node"
cp "/tests/java/tools/jackson/databind/node/JsonNodeStringValueTest.java" "src/test/java/tools/jackson/databind/node/JsonNodeStringValueTest.java"

# Run the specific test class
./mvnw -B -q -ff -ntp test -Dtest=JsonNodeStringValueTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
