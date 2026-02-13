#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-mock/src/test/java/retrofit"
cp "/tests/retrofit-mock/src/test/java/retrofit/MockRestAdapterTest.java" "retrofit-mock/src/test/java/retrofit/MockRestAdapterTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RequestBuilderTest.java" "retrofit/src/test/java/retrofit/RequestBuilderTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit module
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the specific test classes for this PR
# RequestBuilderTest is in the retrofit module
# MockRestAdapterTest is in the retrofit-mock module
mvn test -Dtest=RequestBuilderTest -Dmaven.javadoc.skip=true -pl retrofit
test_status=$?

# Only run MockRestAdapterTest if RequestBuilderTest passed
if [ $test_status -eq 0 ]; then
  mvn test -Dtest=MockRestAdapterTest -Dmaven.javadoc.skip=true -pl retrofit-mock
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
