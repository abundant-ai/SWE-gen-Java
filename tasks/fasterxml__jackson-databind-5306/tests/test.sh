#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind"
cp "/tests/java/tools/jackson/databind/ObjectMapperTest.java" "src/test/java/tools/jackson/databind/ObjectMapperTest.java"
mkdir -p "src/test/java/tools/jackson/databind/module"
cp "/tests/java/tools/jackson/databind/module/SimpleModuleTest.java" "src/test/java/tools/jackson/databind/module/SimpleModuleTest.java"

# Run specific JUnit test classes using Maven wrapper
# The test files are ObjectMapperTest and SimpleModuleTest
./mvnw test -Dtest=ObjectMapperTest,SimpleModuleTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
