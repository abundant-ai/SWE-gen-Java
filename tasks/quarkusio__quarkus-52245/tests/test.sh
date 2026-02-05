#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-framework/junit-config/src/main/java/io/quarkus/test/config"
cp "/tests/test-framework/junit-config/src/main/java/io/quarkus/test/config/TestConfigProviderResolver.java" "test-framework/junit-config/src/main/java/io/quarkus/test/config/TestConfigProviderResolver.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl test-framework/junit-config -am \
  clean install

# Run tests for the affected module
mvn -e -B --settings .github/mvn-settings.xml \
  -pl test-framework/junit-config \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
