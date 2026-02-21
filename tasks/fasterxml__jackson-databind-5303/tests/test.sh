#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/creators"
cp "/tests/java/tools/jackson/databind/deser/creators/NoParamsCreatorDefault5045Test.java" "src/test/java/tools/jackson/databind/deser/creators/NoParamsCreatorDefault5045Test.java"
mkdir -p "src/test/java/tools/jackson/databind/introspect"
cp "/tests/java/tools/jackson/databind/introspect/DefaultCreatorDetection4584Test.java" "src/test/java/tools/jackson/databind/introspect/DefaultCreatorDetection4584Test.java"
mkdir -p "src/test/java/tools/jackson/databind/introspect"
cp "/tests/java/tools/jackson/databind/introspect/DefaultCreatorResolution4620Test.java" "src/test/java/tools/jackson/databind/introspect/DefaultCreatorResolution4620Test.java"

# Run only the specific test classes from the PR
./mvnw -B -ff -ntp test -Dtest=NoParamsCreatorDefault5045Test,DefaultCreatorDetection4584Test,DefaultCreatorResolution4620Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
