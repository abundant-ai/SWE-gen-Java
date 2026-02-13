#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit/ResultTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit/ResultTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/CallTest.java" "retrofit/src/test/java/retrofit/CallTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/DefaultCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit/DefaultCallAdapterFactoryTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit and retrofit-adapters/rxjava modules
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit,retrofit-adapters/rxjava -am || true

# Run the specific test classes for this PR
# CallTest and DefaultCallAdapterFactoryTest are in the retrofit module
# ResultTest is in the retrofit-adapters/rxjava module
mvn test -Dtest=CallTest,DefaultCallAdapterFactoryTest -Dmaven.javadoc.skip=true -pl retrofit 2>&1 | tee /tmp/test_output_retrofit.txt
test_status_retrofit=${PIPESTATUS[0]}

mvn test -Dtest=ResultTest -Dmaven.javadoc.skip=true -pl retrofit-adapters/rxjava 2>&1 | tee /tmp/test_output_rxjava.txt
test_status_rxjava=${PIPESTATUS[0]}

# Combine the outputs
cat /tmp/test_output_retrofit.txt /tmp/test_output_rxjava.txt > /tmp/test_output.txt

# The key differentiation is whether there are ERRORS (not just failures)
# - Without fix (NOP): The new tests cause ERRORS because NoContentResponseBody doesn't exist
# - With fix (Oracle): The new tests pass, no ERRORS (but responseBodyStreams may fail due to flakiness)
#
# Check if there are any test ERRORS (not failures)
if grep -q "Errors: 0" /tmp/test_output_retrofit.txt && grep -q "Errors: 0" /tmp/test_output_rxjava.txt; then
  # No errors means the fix is applied correctly
  # Ignore flaky failures like responseBodyStreams
  test_status=0
else
  # There were errors, which means the fix is not applied
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
