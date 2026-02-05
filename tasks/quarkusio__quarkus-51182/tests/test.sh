#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test"
cp "/tests/extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test/DisallowedMethodsTest.java" "extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test/DisallowedMethodsTest.java"
mkdir -p "extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test"
cp "/tests/extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test/DisallowedMethodsTestServlet.java" "extensions/undertow/deployment/src/test/java/io/quarkus/undertow/test/DisallowedMethodsTestServlet.java"
mkdir -p "extensions/undertow/deployment/src/test/resources"
cp "/tests/extensions/undertow/deployment/src/test/resources/application-disallowed-methods.properties" "extensions/undertow/deployment/src/test/resources/application-disallowed-methods.properties"

# Rebuild the modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/undertow/deployment -am \
    clean install

# Run only the specific test class to verify the changes
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/undertow/deployment \
  -Dtest=DisallowedMethodsTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
