#!/bin/bash

cd /app/src

# Set environment variables for Maven
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/creators"
cp "/tests/java/com/fasterxml/jackson/databind/deser/creators/NoParamsCreatorDefault5045Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/creators/NoParamsCreatorDefault5045Test.java"

# Recompile test classes to pick up any changes from the copied test file
./mvnw -B test-compile

# Run only the specific test class for this PR
./mvnw -B test -Dtest=NoParamsCreatorDefault5045Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
