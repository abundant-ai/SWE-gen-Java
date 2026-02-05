#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "integration-tests/main/src/main/java/io/quarkus/it/rest"
cp "/tests/integration-tests/main/src/main/java/io/quarkus/it/rest/TestResource.java" "integration-tests/main/src/main/java/io/quarkus/it/rest/TestResource.java"
mkdir -p "integration-tests/main/src/test/java/io/quarkus/it/main"
cp "/tests/integration-tests/main/src/test/java/io/quarkus/it/main/JaxRSTestCase.java" "integration-tests/main/src/test/java/io/quarkus/it/main/JaxRSTestCase.java"

# Run the specific test class from this PR
# The test will trigger a Quarkus build which will pick up the fix from solve.sh
mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/main \
  -Dtest=JaxRSTestCase \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
