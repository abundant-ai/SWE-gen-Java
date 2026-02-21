#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/JDKLocaleWithVargarg5231Test.java" "src/test/java/tools/jackson/databind/deser/jdk/JDKLocaleWithVargarg5231Test.java"

# Run ONLY the specific test class from the PR
./mvnw -B test -Dtest=JDKLocaleWithVargarg5231Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
