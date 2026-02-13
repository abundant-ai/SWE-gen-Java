#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/moshi/src/test/java/retrofit"
cp "/tests/retrofit-converters/moshi/src/test/java/retrofit/MoshiConverterTest.java" "retrofit-converters/moshi/src/test/java/retrofit/MoshiConverterTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit module only
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the moshi converter test
mvn test -Dtest=MoshiConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/moshi
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
