#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/OverrideBuildTimeConfigTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/OverrideBuildTimeConfigTest.java"
mkdir -p "integration-tests/test-extension/extension/runtime/src/main/java/io/quarkus/extest/runtime/config"
cp "/tests/integration-tests/test-extension/extension/runtime/src/main/java/io/quarkus/extest/runtime/config/TestMappingBuildTimeRunTime.java" "integration-tests/test-extension/extension/runtime/src/main/java/io/quarkus/extest/runtime/config/TestMappingBuildTimeRunTime.java"

# Rebuild the affected modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl integration-tests/test-extension/extension/runtime,integration-tests/test-extension/extension/deployment -am \
    clean install

# Run the specific test class from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/test-extension/extension/deployment \
  -Dtest=OverrideBuildTimeConfigTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
