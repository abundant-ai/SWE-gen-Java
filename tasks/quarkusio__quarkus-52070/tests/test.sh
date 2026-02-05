#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/startup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/startup/StartupNonBlockingAnnotationTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/startup/StartupNonBlockingAnnotationTest.java"
mkdir -p "extensions/vertx/deployment/src/test/java/io/quarkus/vertx/arc"
cp "/tests/extensions/vertx/deployment/src/test/java/io/quarkus/vertx/arc/StartupAnnotationTest.java" "extensions/vertx/deployment/src/test/java/io/quarkus/vertx/arc/StartupAnnotationTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl extensions/arc/deployment,extensions/vertx/deployment -am \
  clean install

# Run the specific test classes from this PR
# StartupNonBlockingAnnotationTest and StartupAnnotationTest
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/arc/deployment,extensions/vertx/deployment \
  -Dtest=StartupNonBlockingAnnotationTest,StartupAnnotationTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
