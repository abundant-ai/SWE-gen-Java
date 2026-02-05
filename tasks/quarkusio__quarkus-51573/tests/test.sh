#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateQuarkiverseExtension"
cp "/tests/integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateQuarkiverseExtension/quarkus-my-quarkiverse-ext_integration-tests_pom.xml" "integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateQuarkiverseExtension/quarkus-my-quarkiverse-ext_integration-tests_pom.xml"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl integration-tests/maven -am \
  clean install

# Run the specific test method
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=CreateExtensionMojoIT#testCreateQuarkiverseExtension \
  -pl integration-tests/maven \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
