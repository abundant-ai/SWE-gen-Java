#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-framework/junit5-component/src/main/java/io/quarkus/test/component"
cp "/tests/test-framework/junit5-component/src/main/java/io/quarkus/test/component/ComponentContainer.java" "test-framework/junit5-component/src/main/java/io/quarkus/test/component/ComponentContainer.java"
mkdir -p "test-framework/junit5-component/src/main/java/io/quarkus/test/component"
cp "/tests/test-framework/junit5-component/src/main/java/io/quarkus/test/component/QuarkusComponentTestClassLoader.java" "test-framework/junit5-component/src/main/java/io/quarkus/test/component/QuarkusComponentTestClassLoader.java"

# Rebuild the module to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl test-framework/junit5-component -am \
    clean install

# Run the tests in the junit5-component module to verify the changes
mvn -e -B --settings .github/mvn-settings.xml \
  -pl test-framework/junit5-component \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
