#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/offline"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/offline/StartOfflineSchemaManagementTest.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/offline/StartOfflineSchemaManagementTest.java"
mkdir -p "extensions/hibernate-reactive/deployment/src/test/java/io/quarkus/hibernate/reactive/offline"
cp "/tests/extensions/hibernate-reactive/deployment/src/test/java/io/quarkus/hibernate/reactive/offline/StartOfflineSchemaManagementTest.java" "extensions/hibernate-reactive/deployment/src/test/java/io/quarkus/hibernate/reactive/offline/StartOfflineSchemaManagementTest.java"

# Rebuild the extensions after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl extensions/hibernate-orm/runtime,extensions/hibernate-orm/deployment,extensions/hibernate-reactive/runtime,extensions/hibernate-reactive/deployment -am \
  clean install

# Run the specific test classes from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/hibernate-orm/deployment,extensions/hibernate-reactive/deployment \
  -Dtest=StartOfflineSchemaManagementTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
