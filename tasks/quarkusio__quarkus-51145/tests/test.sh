#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/deployment/src/test/java/io/quarkus/deployment/dev"
cp "/tests/core/deployment/src/test/java/io/quarkus/deployment/dev/RecompilationDependenciesProcessorTest.java" "core/deployment/src/test/java/io/quarkus/deployment/dev/RecompilationDependenciesProcessorTest.java"
mkdir -p "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model"
cp "/tests/core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/Address.java" "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/Address.java"
mkdir -p "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model"
cp "/tests/core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/ContactMapper.java" "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/ContactMapper.java"
mkdir -p "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model"
cp "/tests/core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/ContactMapperWhichIsDetectedMultipleTimes.java" "core/deployment/src/test/java/io/quarkus/deployment/dev/recompile_dependencies/model/ContactMapperWhichIsDetectedMultipleTimes.java"
mkdir -p "integration-tests/devmode/src/test/java/io/quarkus/test/reload"
cp "/tests/integration-tests/devmode/src/test/java/io/quarkus/test/reload/AddressData.java" "integration-tests/devmode/src/test/java/io/quarkus/test/reload/AddressData.java"
mkdir -p "integration-tests/devmode/src/test/java/io/quarkus/test/reload"
cp "/tests/integration-tests/devmode/src/test/java/io/quarkus/test/reload/AddressMapper.java" "integration-tests/devmode/src/test/java/io/quarkus/test/reload/AddressMapper.java"
mkdir -p "integration-tests/devmode/src/test/java/io/quarkus/test/reload"
cp "/tests/integration-tests/devmode/src/test/java/io/quarkus/test/reload/ContactData.java" "integration-tests/devmode/src/test/java/io/quarkus/test/reload/ContactData.java"
mkdir -p "integration-tests/devmode/src/test/java/io/quarkus/test/reload"
cp "/tests/integration-tests/devmode/src/test/java/io/quarkus/test/reload/RecompilationDependenciesBuildCompatibleExtension.java" "integration-tests/devmode/src/test/java/io/quarkus/test/reload/RecompilationDependenciesBuildCompatibleExtension.java"
mkdir -p "integration-tests/devmode/src/test/java/io/quarkus/test/reload"
cp "/tests/integration-tests/devmode/src/test/java/io/quarkus/test/reload/RecompilationDependenciesDevModeTest.java" "integration-tests/devmode/src/test/java/io/quarkus/test/reload/RecompilationDependenciesDevModeTest.java"

# Rebuild the modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl core/deployment -am \
    clean install

# Run the specific test class from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl core/deployment \
  -Dtest=RecompilationDependenciesProcessorTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
