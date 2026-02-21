#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/ser/jdk"
cp "/tests/java/tools/jackson/databind/ser/jdk/JavaUtilDateSerializationTest.java" "src/test/java/tools/jackson/databind/ser/jdk/JavaUtilDateSerializationTest.java"

# Run only the specific test class from the PR
./mvnw -B -ntp test -Dtest=tools.jackson.databind.ser.jdk.JavaUtilDateSerializationTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
