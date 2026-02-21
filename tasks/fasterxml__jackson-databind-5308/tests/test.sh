#!/bin/bash

cd /app/src

# Set environment variables for tests
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/creators"
cp "/tests/java/tools/jackson/databind/deser/creators/NoParamsCreator5318Test.java" "src/test/java/tools/jackson/databind/deser/creators/NoParamsCreator5318Test.java"
mkdir -p "src/test/java/tools/jackson/databind/deser/creators"
cp "/tests/java/tools/jackson/databind/deser/creators/TestConstructFromMap.java" "src/test/java/tools/jackson/databind/deser/creators/TestConstructFromMap.java"
mkdir -p "src/test/java/tools/jackson/databind/struct"
cp "/tests/java/tools/jackson/databind/struct/PojoAsArrayRoundtripTest.java" "src/test/java/tools/jackson/databind/struct/PojoAsArrayRoundtripTest.java"

# Run only the specific test classes from the PR using Maven
./mvnw -B test -Dtest=NoParamsCreator5318Test,TestConstructFromMap,PojoAsArrayRoundtripTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
