#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test"
cp "/tests/extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test/ExceptionInReaderWithDisabledBuiltInMapperTest.java" "extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test/ExceptionInReaderWithDisabledBuiltInMapperTest.java"

# Rebuild the affected modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/resteasy-reactive/rest-common/runtime,extensions/resteasy-reactive/rest/deployment,extensions/resteasy-reactive/rest-jackson/deployment,independent-projects/resteasy-reactive/server/runtime -am \
    clean install

# Run the specific test class from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/resteasy-reactive/rest-jackson/deployment \
  -Dtest=ExceptionInReaderWithDisabledBuiltInMapperTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
