#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/AbstractModuleEnableNativeAccessManifestTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/AbstractModuleEnableNativeAccessManifestTest.java"
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ModuleEnableNativeAccessFastJarManifestTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ModuleEnableNativeAccessFastJarManifestTest.java"
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ModuleEnableNativeAccessManifestTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ModuleEnableNativeAccessManifestTest.java"

# Rebuild the test module and its dependencies after solve.sh applies fix.patch
# This is necessary because fix.patch modifies core/deployment source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -Dtcks -Prelocations \
  -pl integration-tests/test-extension/extension/deployment -am \
  clean install

# Run the specific test classes (not the entire test suite)
# Use Maven Surefire to run only the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dformat.skip -Denforcer.skip -DskipDocs -Dforbiddenapis.skip \
  -DskipExtensionValidation -DskipCodestartValidation \
  -pl integration-tests/test-extension/extension/deployment \
  test -Dtest=ModuleEnableNativeAccessManifestTest,ModuleEnableNativeAccessFastJarManifestTest

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
