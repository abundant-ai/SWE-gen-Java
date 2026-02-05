#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "independent-projects/resteasy-reactive/server/vertx/src/test/java/org/jboss/resteasy/reactive/server/vertx/test/simple"
cp "/tests/independent-projects/resteasy-reactive/server/vertx/src/test/java/org/jboss/resteasy/reactive/server/vertx/test/simple/PeriodParamTest.java" "independent-projects/resteasy-reactive/server/vertx/src/test/java/org/jboss/resteasy/reactive/server/vertx/test/simple/PeriodParamTest.java"

# Rebuild runtime module to pick up any source changes from fix.patch
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl independent-projects/resteasy-reactive/server/runtime \
    clean install

# Run the specific test classes from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl independent-projects/resteasy-reactive/server/vertx \
  -Dtest=PeriodParamTest \
  -DskipExtensionValidation \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
