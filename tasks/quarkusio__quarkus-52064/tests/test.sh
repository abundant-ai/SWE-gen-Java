#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-framework/junit-internal/src/main/java/io/quarkus/test"
cp "/tests/test-framework/junit-internal/src/main/java/io/quarkus/test/QuarkusDevModeTest.java" "test-framework/junit-internal/src/main/java/io/quarkus/test/QuarkusDevModeTest.java"
mkdir -p "test-framework/junit/src/main/java/io/quarkus/test/junit"
cp "/tests/test-framework/junit/src/main/java/io/quarkus/test/junit/QuarkusIntegrationTestExtension.java" "test-framework/junit/src/main/java/io/quarkus/test/junit/QuarkusIntegrationTestExtension.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies core source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl core/deployment,core/runtime,extensions/vertx-http/runtime,test-framework/junit-internal,test-framework/junit -am \
  clean install

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
